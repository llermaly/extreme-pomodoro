import Foundation
import Speech
import AVFoundation

/// Service for speech recognition using macOS 26+ SpeechAnalyzer APIs
@available(macOS 26.0, *)
@MainActor
final class SpeechRecognitionService: ObservableObject {

    // MARK: - Published Properties

    @Published var isListening = false
    @Published var finalTranscript = ""
    @Published var volatileTranscript = ""
    @Published var errorMessage: String?
    @Published var isModelInstalled = false
    @Published var downloadProgress: Progress?
    @Published var selectedLocale: Locale = SpeechRecognitionService.defaultLocale

    // MARK: - Static Properties

    /// Default locale to use for speech recognition (en-US is well-supported)
    static let defaultLocale = Locale(identifier: "en-US")

    /// Fallback locales to try if the system locale isn't supported
    private static let fallbackLocales = [
        Locale(identifier: "en-US"),
        Locale(identifier: "en-GB"),
        Locale(identifier: "es-ES"),
        Locale(identifier: "es-MX")
    ]

    // MARK: - Private Properties

    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var analyzerFormat: AVAudioFormat?
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var inputSequence: AsyncStream<AnalyzerInput>?
    private var recognizerTask: Task<Void, Never>?

    private var audioEngine: AVAudioEngine?
    private var converter: BufferConverter?

    // MARK: - Initialization

    /// Initialize the speech recognition service
    /// - Parameter deferLocaleSetup: If true, locale detection is deferred until `startListening()` is called.
    ///   This prevents system warnings when the service is created but not immediately used.
    init(deferLocaleSetup: Bool = false) {
        if !deferLocaleSetup {
            // Try to find a supported locale immediately
            Task {
                await findBestLocale()
            }
        }
    }

    /// Find the best supported locale based on user preferences
    private func findBestLocale() async {
        let supportedLocales = await SpeechTranscriber.supportedLocales
        let supportedIdentifiers = Set(supportedLocales.map { $0.identifier(.bcp47) })

        // First, try the current locale
        if supportedIdentifiers.contains(Locale.current.identifier(.bcp47)) {
            selectedLocale = Locale.current
            return
        }

        // Try to match language (e.g., en_CL -> en-US)
        let currentLanguage = Locale.current.language.languageCode?.identifier
        for locale in supportedLocales {
            if locale.language.languageCode?.identifier == currentLanguage {
                selectedLocale = locale
                return
            }
        }

        // Fall back to default locales
        for fallback in Self.fallbackLocales {
            if supportedIdentifiers.contains(fallback.identifier(.bcp47)) {
                selectedLocale = fallback
                return
            }
        }

        // Last resort: use first available
        if let first = supportedLocales.first {
            selectedLocale = first
        }
    }

    // MARK: - Public Methods

    /// Check if speech recognition is available and set up
    func checkAvailability() async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map { $0.identifier(.bcp47) }.contains(selectedLocale.identifier(.bcp47))
    }

    /// Check and request microphone authorization
    func checkMicrophoneAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    /// Set up the transcriber and analyzer
    func setup() async throws {
        // Find best locale if not already done
        await findBestLocale()

        // Create transcriber with volatile results for real-time feedback
        transcriber = SpeechTranscriber(
            locale: selectedLocale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )

        guard let transcriber else {
            throw SpeechRecognitionError.failedToSetupTranscriber
        }

        // Create analyzer with the transcriber module
        analyzer = SpeechAnalyzer(modules: [transcriber])

        // Get the best audio format for the transcriber
        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])

        // Ensure model is available
        try await ensureModel(transcriber: transcriber, locale: selectedLocale)

        isModelInstalled = true
    }

    /// Start listening and transcribing
    func startListening() async throws {
        guard !isListening else { return }

        // Check microphone authorization first
        guard await checkMicrophoneAuthorization() else {
            throw SpeechRecognitionError.microphoneAccessDenied
        }

        // Reset state
        finalTranscript = ""
        volatileTranscript = ""
        errorMessage = nil

        // Set up transcriber if needed
        if transcriber == nil {
            try await setup()
        }

        guard let transcriber, let analyzer, let analyzerFormat else {
            throw SpeechRecognitionError.notSetup
        }

        // Create input stream
        let (sequence, builder) = AsyncStream<AnalyzerInput>.makeStream()
        inputSequence = sequence
        inputBuilder = builder

        // Start result handling task BEFORE starting the analyzer
        recognizerTask = Task {
            do {
                for try await result in transcriber.results {
                    let text = String(result.text.characters)
                    if result.isFinal {
                        finalTranscript += text + " "
                        volatileTranscript = ""
                    } else {
                        volatileTranscript = text
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Speech recognition failed: \(error.localizedDescription)"
                }
            }
        }

        // Set up audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine else {
            throw SpeechRecognitionError.failedToSetupAudio
        }

        // Remove any existing tap
        audioEngine.inputNode.removeTap(onBus: 0)

        // Create converter for format conversion
        let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        converter = BufferConverter()

        // Install tap on input node
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: inputFormat
        ) { [weak self] buffer, _ in
            guard let self else { return }
            Task { @MainActor in
                try? await self.processAudioBuffer(buffer)
            }
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        // Start the analyzer AFTER audio engine is running
        try await analyzer.start(inputSequence: sequence)

        isListening = true
    }

    /// Stop listening
    func stopListening() async {
        guard isListening else { return }

        // Stop audio engine
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        // Finish the input stream
        inputBuilder?.finish()
        inputBuilder = nil
        inputSequence = nil

        // Finalize analyzer
        try? await analyzer?.finalizeAndFinishThroughEndOfInput()

        // Cancel recognizer task
        recognizerTask?.cancel()
        recognizerTask = nil

        isListening = false
    }

    /// Get the current full transcript (final + volatile)
    var currentTranscript: String {
        if volatileTranscript.isEmpty {
            return finalTranscript
        }
        return finalTranscript + volatileTranscript
    }

    // MARK: - Private Methods

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) async throws {
        guard let inputBuilder, let analyzerFormat, let converter else { return }

        let converted = try converter.convertBuffer(buffer, to: analyzerFormat)
        let input = AnalyzerInput(buffer: converted)
        inputBuilder.yield(input)
    }

    private func ensureModel(transcriber: SpeechTranscriber, locale: Locale) async throws {
        // Check if locale is supported
        let supported = await SpeechTranscriber.supportedLocales
        let supportedIdentifiers = supported.map { $0.identifier(.bcp47) }

        guard supportedIdentifiers.contains(locale.identifier(.bcp47)) else {
            throw SpeechRecognitionError.localeNotSupported
        }

        // Check if already installed
        let installed = await SpeechTranscriber.installedLocales
        let installedIdentifiers = installed.map { $0.identifier(.bcp47) }

        if installedIdentifiers.contains(locale.identifier(.bcp47)) {
            return
        }

        // Download if needed
        if let downloader = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            downloadProgress = downloader.progress
            try await downloader.downloadAndInstall()
            downloadProgress = nil
        }
    }

    /// Get list of supported locales
    func getSupportedLocales() async -> [Locale] {
        return await SpeechTranscriber.supportedLocales
    }
}

// MARK: - Buffer Converter Helper (based on Apple's sample)

@available(macOS 26.0, *)
private class BufferConverter {
    enum Error: Swift.Error {
        case failedToCreateConverter
        case failedToCreateConversionBuffer
        case conversionFailed(NSError?)
    }

    private var converter: AVAudioConverter?

    func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let inputFormat = buffer.format

        // If formats match, no conversion needed
        guard inputFormat != format else {
            return buffer
        }

        // Create or update converter if needed
        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: inputFormat, to: format)
            // Sacrifice quality of first samples to avoid timestamp drift
            converter?.primeMethod = .none
        }

        guard let converter else {
            throw Error.failedToCreateConverter
        }

        // Calculate output buffer capacity
        let sampleRateRatio = converter.outputFormat.sampleRate / converter.inputFormat.sampleRate
        let scaledInputFrameLength = Double(buffer.frameLength) * sampleRateRatio
        let frameCapacity = AVAudioFrameCount(scaledInputFrameLength.rounded(.up))

        guard let conversionBuffer = AVAudioPCMBuffer(pcmFormat: converter.outputFormat, frameCapacity: frameCapacity) else {
            throw Error.failedToCreateConversionBuffer
        }

        var nsError: NSError?
        var bufferProcessed = false

        let status = converter.convert(to: conversionBuffer, error: &nsError) { packetCount, inputStatusPointer in
            defer { bufferProcessed = true }
            inputStatusPointer.pointee = bufferProcessed ? .noDataNow : .haveData
            return bufferProcessed ? nil : buffer
        }

        guard status != .error else {
            throw Error.conversionFailed(nsError)
        }

        return conversionBuffer
    }
}

// MARK: - Errors

enum SpeechRecognitionError: LocalizedError {
    case failedToSetupTranscriber
    case notSetup
    case failedToSetupAudio
    case failedToCreateConverter
    case failedToCreateBuffer
    case localeNotSupported
    case microphoneAccessDenied
    case modelDownloadFailed

    var errorDescription: String? {
        switch self {
        case .failedToSetupTranscriber:
            return "Failed to set up speech transcriber"
        case .notSetup:
            return "Speech recognition not set up"
        case .failedToSetupAudio:
            return "Failed to set up audio input"
        case .failedToCreateConverter:
            return "Failed to create audio converter"
        case .failedToCreateBuffer:
            return "Failed to create audio buffer"
        case .localeNotSupported:
            return "Current locale is not supported for speech recognition. Please check System Settings > General > Keyboard > Dictation to enable on-device dictation."
        case .microphoneAccessDenied:
            return "Microphone access denied. Please enable microphone access in System Settings > Privacy & Security > Microphone."
        case .modelDownloadFailed:
            return "Failed to download speech recognition model. Please check your internet connection."
        }
    }
}
