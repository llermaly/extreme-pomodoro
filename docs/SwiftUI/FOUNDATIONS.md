
App principles
Exploring the structure of a SwiftUI app
Walk through code that explores the structure of a SwiftUI app.

SwiftUI is a declarative framework that helps you compose the user interface of your app. The principle building blocks that form the structure of a SwiftUI app are the App, Scene, and View protocols. This sample introduces you to these protocols by walking through lines of code, and explaining what’s happening and why.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
App structure
An app structure describes the content and behavior of your app, and each SwiftUI app has one and only one main app structure. This sample defines its app structure in the MyApp.swift file. Let’s take a look at the contents of that file.

Step 1

To access the symbols and features of SwiftUI, the app uses an import declaration to import the SwiftUI framework.

Note

For more information, see Import Declaration in The Swift Programming Language.

Step 2

To indicate the entry point of the SwiftUI app, the sample applies the @main attribute to the app structure.

The entry point is responsible for the start up of the app.

Important

A SwiftUI app contains one and only one entry point. Attempting to apply @main to more than one structure in the app results in a compiler error.

Step 3

The MyApp structure conforms to the App protocol, and provides the content of the app and its behavior.

Step 4

The structure implements the computed property body, which is a requirement of the App protocol.

This property returns the contents of your app described as a Scene. A scene contains the view hierarchy that defines the app’s user interface. SwiftUI provides different types of scenes including WindowGroup, Window, DocumentGroup, and Settings.

Step 5

This sample uses a WindowGroup scene to represent the main window that the app displays.

SwiftUI provides platform-specific behaviors for WindowGroup. For instance, in macOS and iPadOS, a person can open more than one window from the group. And in macOS, a person can combine multiple instances of the window group into a set of tabs.

Tip

If you’re creating a document-based app such as a word processor or text editor, you can use the DocumentGroup scene to open, save, and edit documents. For more information, see Building a document-based app with SwiftUI.

Step 6

The scene contains ContentView, a custom view that creates a view hierarchy that consists of an image and text.

Keep reading to learn how ContentView composes the view hierarchy.

MyApp.swift
import SwiftUI


@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

Preview
An image showing the contents of content view. The content view displays a globe symbol with an accent color that appears above the line of text: Hello, world!
Section 2
Content view
In SwiftUI, a scene contains the view hierarchy that an app displays as its user interface. A view hierarchy defines the layout of views relative to other views. In this sample, a WindowGroup scene contains the view hierarchy that ContentView composes using other views.

An illustration showing the view hierarchy of the sample app. At the top of the illustration is the label View hierarchy. Under the label is box that contains the label WindowGroup. An arrow extends from the box and points to another box that contains the label ContentView. An arrow extends from the ContentView box and points to a box labeled VStack. Two arrows extend from the VStack box. One arrow points to a box labeled Image. The second arrow points to a box labeled Text.
Step 1

The source code begins by importing the SwiftUI framework.

Without the import declaration, ContentView wouldn’t have access to symbols in SwiftUI.

Step 2

ContentView is a structure that conforms to the View protocol.

A view defines one or more visual elements that appear somewhere on a screen. A view is typically made up of other views, creating a view hierarchy.

Step 3

ContentView implements the computed property body, just like the ‘MyApp’ structure does in the previous section.

Note

Implementing body is a common pattern that you see throughout your SwiftUI code; for instance, when a structure conforms to protocols such as App, Scene, and View.

Step 4

ContentView contains the SwiftUI-provided view VStack, which arranges subviews vertically.

A VStack simultaneously renders any on- or off-screen views it contains. Using VStack is ideal when you have a small number of subviews. However, if your app needs to display many more subviews, consider using LazyVStack, which only renders the views when the app needs to display them onscreen.

Experiment

Replace VStack with either HStack or LazyHStack to arrange subviews horizontally.

Step 5

The first subview in VStack is Image, a view that displays an image.

The sample displays an image of a globe using the initializer method init(systemName:). This method creates an image view that displays a system symbol image. Symbol images like globe come from SF Symbols, a library of icons that you can use in your app.

Step 6

ContentView applies the view modifier imageScale(_:) to the image view to scale the image within the view to the relative size Image.Scale.large.

Experiment

Change Image.Scale.large to another scale size. For a list of sizes, see Image.Scale.

Step 7

The foregroundColor(_:) modifier adds color to the image view.

In this sample, ContentView applies the semantic color accentColor, which reflects the accent color of the system or app. To learn more about color representations, see Color.

Experiment

Change the foreground color to another semantic color such as primary or a standard color like teal.

Step 8

The second subview of VStack is Text, a view that displays one or more lines of read-only text.

Experiment

Replace “Hello, world!” with “Hello, your name!” or other text.

Step 9

ContentView applies the padding(_:_:) modifier to the VStack, adding a platform-specific default amount of padding — that is, space — to the edges of the VStack view.

Experiment

You can specify which edges and amount of padding to apply by providing edges and length parameter values; for example, padding([.bottom, .trailing], 20). Change the padding edges and amount or comment the line of code to see what effect it has on the view.

Step 10

When you run the sample app, it displays the scene that contains the view hierarchy described in ContentView.

Experiment

Build and run the sample using Xcode. Then play around with code by following the suggested experiments mentioned in the previous steps.

An screenshot of the sample app, displaying a globe symbol with an accent foreground color that appears above the line of text: Hello, world!
Next
Specifying the view hierarchy of an app using a scene
A scene contains the view hierarchy of your app.



App principles
Specifying the view hierarchy of an app using a scene
A scene contains the view hierarchy of your app.

SwiftUI provides building blocks that help you create the user interface of your app. One of those building blocks is Scene, which contains a view hierarchy that defines the user interface of your app. You can specify your app’s view hierarchy in a scene that SwiftUI provides, or you can create a custom scene. This tutorial walks you through both approaches.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Add a scene to the app
This sample uses a journaling app as an example. To describe the view hierarchy of the app’s user interface, the MyApp structure declares a scene and its contents. Let’s take a look at the structure and its scene.

Step 1

The sample defines an entry point using the @main attribute and the structure MyApp, which conforms to the App protocol.

Note

The entry point and MyApp structure are responsible for the start up of the app. Each SwiftUI app has one and only one entry point and main app structure.

Step 2

The MyApp structure implements the computed property body, which returns a scene.

The computed body property can return one or more primary and secondary scenes.

Step 3

In this sample, body returns the primary scene WindowGroup, which describes the view hierarchy of the sample’s main window.

The WindowGroup scene is one of the more commonly used scenes. It provides platform-specific behaviors for your app, such as supporting multiple windows in macOS and iPadOS. For more information about this scene as well as other scenes that SwiftUI provides, see Scenes.

Step 4

The root node of the view hierarchy is TabView, a container view that provides tabs that people can use to switch between different subviews.

Step 5

The TabView contains two subviews, ContentView and SettingsView.

Both are custom views. ContentView displays a list of journal entries, and SettingsView displays other views that let people edit the settings for the app, such as the account associated with the journal.

Step 6

Each of these views apply the tabItem(_:) modifier, which tells the TabView the image and text to display in each tab.

Step 7

When the sample app runs, it displays the view hierarchy described in the WindowGroup scene, which is a tab interface with two tabs: Journal and Settings.

A screenshot of the sample app running on an iPhone. An Add button, which is a plus sign, appears in the toolbar along the top of the screen. Below the toolbar is the title Journal, followed by two sample journal entries. At the bottom of the screen are the two tab bar items, Journal and Settings, with the Journal tab selected.
Section 2
Define another view hierarchy
The sample app runs on multiple devices including iPhone and Mac. But the view hierarchy described in the previous section doesn’t look quite right in macOS. So the sample declares another view hierarchy that takes advantage of features specific to the Mac.

Step 1

Here’s the view hierarchy discussed in the previous section.

The sample defines the view hierarchy using a WindowGroup scene that contains a TabView. In turn, the TabView contains two subviews: ContentView and SettingsView.

Let’s look at the view hierarchy the sample defines for macOS.

Step 2

The sample defines the other view hierarchy in a WindowGroup scene.

Step 3

Unlike the previous hierarchy, the root node of this hierarchy is the custom view, AlternativeContentView.

Note

The root node of the previous view hierarchy is the container view, TabView.

Step 4

The sample uses the secondary scene Settings to provide a Settings menu item that’s available in the app menu, which is a common feature of Mac apps.

Note

The Settings scene is only available in macOS.

Step 5

The Settings scene contains the custom view, SettingView, which displays app settings in a window that the Settings menu item provides.

With two separate view hierarchies defined, the sample must specify which one to use based on the target platform.

Step 6

To compile the first view hierarchy for iOS, the sample uses a platform conditional compilation block that tells the Swift compiler to compile the code only when the target platform is iOS.

Note

A conditional compilation block tells the Swift compiler to conditionally compile the code block depending on the value of one or more compilation conditions. For more information about conditional compilation blocks, see Compiler Control Statements

Step 7

The app uses a separate platform conditional to compile the scenes that the Mac app uses.

Step 8

Here’s how the scenes appear when you run the app on iPhone and Mac.

The iPhone version of the app displays a scene with a tabbed user interface, while the Mac version displays a scene with split view interface. The Mac app also displays the secondary scene Settings when you select the Preferences item under the app menu.

An image showing the sample app running on a Mac and iPhone.
Section 3
Create custom scenes
The source code in the MyApp structure does the job of defining view hierarchies different versions of the sample app, but the code is lengthy making it difficult to maintain. One improvement that can help make the code more readable and easier to maintain is to use custom scenes. A custom scene is one that you compose from other scenes.

Step 1

To describe the scene that displays on iOS devices, the sample includes the custom scene MyScene, which is a structure that conforms to the Scene protocol.

Step 2

A structure that conforms to Scene must implement the computed property body, just like structures that conform to the App protocol do.

Step 3

The implementation of body uses the same code from the MyApp structure, covered in the Add a scene to the app section of this tutorial.

Step 4

For macOS, the sample includes another custom scene, MyAlternativeScene, which is another structure that conforms to Scene.

Step 5

It too implements the computed body property.

Step 6

The code for this scene is the same code from the MyApp structure, discussed in the Define another view hierarchy section.

Note

The computed body property includes the secondary scene Settings. This scene is only available in macOS, so it’s placed inside a platform conditional compilation block.

MyAlternativeScene.swift
import SwiftUI


struct MyAlternativeScene: Scene {
    var body: some Scene {
        WindowGroup {
            AlternativeContentView()
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}

No Preview
Section 4
Refactor the code to use custom scenes
With the MyScene and MyAlternativeScene in place, the final step is to refactor the code in the MyApp structure so that it uses the custom scenes.

Step 1

Before refactoring the MyApp structure to use the custom scenes, the code is fairly long and complex.

This approach can make the implementation of computed property body more difficult to maintain.

Step 2

However, after refactoring the code, the MyApp structure is easier to read and maintain.

Experiment

Change the code so that the sample uses MyScene in macOS and MyAlternativeScene in iOS.

MyApp.swift
import SwiftUI


@main
struct MyApp: App {
    var body: some Scene {
        #if os(iOS)
        MyScene()
        #elseif os(macOS)
        MyAlternativeScene()
        #endif
    }
}



Maintaining the adaptable sizes of built-in views
Keep your app’s view layouts fluid on any device for each type of content your app displays.

The views you define with SwiftUI either directly contain views that SwiftUI provides, or use other custom views that contain these built-in views. SwiftUI views determine their own size, and understanding how to modify the size of built-in views while preserving their adaptability is the best way to create a fluid layout without complicating your code.

Text and symbols
When defining the layout for your app, text and symbols play a central role in conveying information to people – in navigation links, button labels, tables, and more. Text and symbols that display information or label other elements need to have enough space to display their contents.

Text
A Text view displays read-only text. Its contents could be a short String, like the title of a play or the heading of a section. A Text view could also display a much longer String, like all of the actors’ lines for a scene in the play.

When you declare a Text view in your layout, give the system semantic information about your text with the Font attribute. The system chooses font faces and sizes so that, for example, a Text with the title font is more prominent than one with body or caption.

Text("Hamlet")
    .font(.largeTitle)
Text("by William Shakespeare")
    .font(.caption)
    .italic()
Two lines of center-aligned text. The first line is the word, Hamlet, in a large font. The second line is, by William Shakespeare, in a smaller, italic font.
A Text view can adjust to some space constraints with line-wrapping or truncation, but it doesn’t change font size to accommodate situations where its ideal size is smaller or larger than the available space.

For more information about localization, see Preparing views for localization. For guidance about supporting Dynamic Type, see Applying custom fonts to text.

Symbols
Symbols, such as the iconography that SF Symbols provides, can denote common app features, like folders, heart shapes for favorites, or a camera icon to access the camera. Effective symbols streamline your app’s UI, and are easily recognizable by the people who use your app. You can customize their colors and sizes using standard view modifiers provided in SwiftUI. Even though you specify a system or custom symbol in an Image, treat SF Symbols more like text. To adjust the size and weight of a symbol, specify a semantic Font, like title, just like you would for a Text view.

The following example uses an HStack to create a row of three Image views that display icons from SF Symbols.

HStack {
    Image(systemName: "folder.badge.plus")
    Image(systemName: "heart.circle.fill")
    Image(systemName: "alarm")
}
.symbolRenderingMode(.multicolor)
.font(.largeTitle)
A row of symbols. The left symbol is a folder with a plus symbol in the upper-right corner. The middle symbol is a heart inside of a circle. On the right is a symbol of an alarm clock.
Labels
To use both text and a symbol to represent a single element in your app, use a Label. A Label takes care of matching its title and icon sizes and their alignment. The following code defines a Label that combines an SF Symbol of some books, with some text for its title. The Label applies the largeTitle font to both the icon and the title. The titleAndIcon style tells the view to display both its title and icon, overriding any built-in or custom LabelStyle that a containing view might specify.

Label("Favorite Books", systemImage: "books.vertical")
    .labelStyle(.titleAndIcon)
    .font(.largeTitle)
A line art graphic of some books side by side to the left of the phrase, Favorite Books.
Controls
Views that people interact with come in discrete sizes, to maintain consistency when several elements of the same type appear together, like in a Settings pane. Controls also need to be large enough for people to accurately click or tap. You can use view modifiers to choose among these sizes. For example, you can use the controlSize(_:) modifier to make a control smaller or larger, or you can use the progressViewStyle(_:) modifier to choose a linear or circular appearance for a progress bar.

The following example shows a Picker and a Button with different ControlSize values.

VStack {
    HStack {
        Picker("Choice", selection: $choice) {
            choiceList()
        }
        Button("OK") {
            applyChanges()
        }
    }
    .controlSize(.mini)
    HStack {
        Picker("Choice", selection: $choice) {
            choiceList()
        }
        Button("OK") {
            applyChanges()
        }
    }
    .controlSize(.large)
}
Two rows of controls. The top row has a small picker control to the left, and a small OK button to the right. The bottom row has a larger picker control on the left, and a larger OK button to the right.
There are general-purpose controls like Menu and Link, and specialized views like EditButton and ColorPicker. Use these views to provide familiar UI elements rather than creating custom controls that you’ll need to maintain. To explore more of these built-in views, see Controls and indicators.

Images and shapes
Graphical elements, such as images and shapes, can add a level of visual enhancement for your app. These can vary from product images for a shopping app, achievements for a game, or a dynamic background pattern you create by layering and aligning various shapes.

Images
Display photos and other rich graphics in an Image. By default, an Image displays at the asset’s original size. You can add modifiers like resizable(capInsets:resizingMode:) and scaledToFit() or scaledToFill() to scale it to the available space.

Image("Yellow_Daisy")
    .resizable()
    .scaledToFit()
A photo of a daisy in full bloom.
If you’re accessing an image asset from a server, use an AsyncImage to handle the download while keeping your app responsive.

For more information about working with images, see Fitting images into available space.

Shapes
SwiftUI provides several common shapes, and modifiers to change their size, color, or other aspects of their appearance. Use a single shape or a composition of multiple shapes to create a background, border, or other visual element. You can define a shape’s size with a modifier like frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:), or allow it to fill all available space.

The following example shows three different shapes. The foregroundColor(_:) on each shape customizes that shape’s fill color. The RoundedRectangle includes values for the cornerRadius and style parameters to define the rounded corners. The HStack provides some default spacing between each shape and, to give each shape a square space to fill, the aspectRatio(_:contentMode:) modifier makes the HStack three times as wide as it is tall.

HStack {
    Rectangle()
        .foregroundColor(.blue)
    Circle()
        .foregroundColor(.orange)
    RoundedRectangle(cornerRadius: 15, style: .continuous)
        .foregroundColor(.green)
}
.aspectRatio(3.0, contentMode: .fit)
A rectangle, a circle, and a rectangle with rounded corners, all of similar size.
For an example of the rich possibilities of composing shapes, see Drawing paths and shapes.


View layout
Scaling views to complement text
Construct a layout that adapts to font styles, Dynamic Type, and varying string lengths.

When composing a view that includes text, it’s important to define other elements relative to that text, like a symbol or padding, so the view adapts to the text’s size.

The symbol and padding can adapt as the text content changes for localizations, Dynamic Type sizes, or to display a different phrase.

Project files
Xcode 14 or later
Section 1
Associate content with the text
This example coordinates a name and a symbol to represent a single item with a Label. It also defines a Capsule in a background(alignment:content:) modifier, to maintain a consistent margin around the Label.

A purple capsule shape with a leaf symbol and the word, chives, and a wider purple capsule shape with a leaf symbol and the words, fern-leaf lavender.
Step 1

To make KeywordBubble reusable, the label’s text and symbol name are properties of the view. When another view uses a KeywordBubble, that other view specifies the text and symbol to display.

Step 2

Label is a built-in view that arranges the text and the symbol, the main content of this view. Label adjusts the symbol’s size and aligns the two pieces of content, so you don’t have to manually align the Text with an Image.

The systemImage parameter retrieves a system image to display. To look up the names of available system images, download the SF Symbols app.

Step 3

A Label applies the same font to both the text and image. An image that displays an SF Symbol uses font information to determine its size and position.

Experiment

Try some other Font.TextStyle values, like Font.TextStyle.largeTitle or Font.TextStyle.caption to see how the sizes of the word and the leaf symbol change.

Step 4

Using the padding(_:_:) modifier without any arguments creates a view that adds a default amount of space on all four edges of the view that it modifies.

Step 5

The Capsule shape provides a rounded rectangle that expands to fill its container. The fill(_:style:) modifier specifies the color of the capsule, and opacity(_:) gives the capsule a bit of transparency.

Step 6

To specify that the capsule belongs behind the text and symbol, the code defines the capsule inside a background(alignment:content:) modifier.

The capsule’s size includes the padding around the Label because the background modifier is after the padding modifier.

KeywordBubble.swift
import SwiftUI


// Source file for Section 1
struct KeywordBubbleDefaultPadding: View {
    let keyword: String
    let symbol: String
    var body: some View {
        Label(keyword, systemImage: symbol)
            .font(.title)
            .foregroundColor(.white)
            .padding()
            .background(.purple.opacity(0.75), in: Capsule())
    }
}


struct KeywordBubbleDefaultPadding_Previews: PreviewProvider {
    static let keywords = ["chives", "fern-leaf lavender"]
    static var previews: some View {
        VStack {
            ForEach(keywords, id: \.self) { word in
                KeywordBubbleDefaultPadding(keyword: word, symbol: "leaf")
            }
        }
    }
}



No Preview
Section 2
Preview a custom view in Xcode
Xcode provides a Canvas where you can preview layouts as your code changes. To see a preview of a custom SwiftUI view, implement the PreviewProvider protocol. The Canvas can display several variants of your view so you can see how it adapts to different environments.

Step 1

You can see a live preview of a SwiftUI View in Xcode side by side with the code that defines it.

Step 2

To preview a custom view, implement the PreviewProvider protocol by defining a static previews property.

Step 3

To verify whether your view works with a range of inputs, configure more than one preview, and define static data to display in each preview.

The keywords array defines two String values of different lengths. The previews property defines both of these in a VStack to display how the KeywordBubble view adapts to the text length.

Step 4

This line defines the KeywordBubble view, and provides the text and image for it.

Experiment

Try replacing leaf with the name of another SF Symbol. For more information about customizing the appearance of SF Symbols, see SF Symbols in the Human Interface Guidelines.

Step 5

To verify how your view looks with the full range of Dynamic Type text sizes, choose Variants > Dynamic Type Variants in the Xcode Canvas view.

Part of an Xcode window, with code on the left and iPhone devices on the right. At the bottom of the window is a floating row of buttons. A button with six rectangles on it is selected. The menu above that button has three options: Color Scheme Variants, Orientation Variants, and Dynamic Type Variants. Dynamic Type Variants is selected.
Section 3
Adjust dimensions with ScaledMetric
The default values for dimensions such as the padding on this view, or the width and height of a frame aren’t always going to work for your layout. In many cases, you can design a small set of values to use across a range of environments. But there are over one hundred combinations of Dynamic Type settings and Font.TextStyle options, so choosing a specific value for each isn’t really practical. When you need to provide a numeric value that adapts to the environment’s effective font size, use the ScaledMetric property wrapper.

Step 1

Look at the KeywordBubbleDefaultPadding preview for the AX 5 text size. With the default padding, the tip of the leaf symbol collides with the edge of the Capsule shape.

To keep the content inside the bubble at large text sizes without adding too much padding for small text sizes, define a custom padding metric that scales with the text size.

Step 2

This paddingWidth variable provides a value of 14.5 for content in a DynamicTypeSize.large Dynamic Type environment. With the ScaledMetric property wrapper, the value is proportionally larger or smaller, according to the current value of dynamicTypeSize.

For more information about using ScaledMetric to scale dimensions in proportion to text, see Applying custom fonts to text.

Step 3

The Label uses the Font.TextStyle.title style to define the text size.

Specifying Font.TextStyle.title for the textStyle parameter indicates that this metric scales with, or is relative to, the title style.

Step 4

The padding(_:) modifier adds a specific amount of space, in points, around the label on all four edges. Because paddingWidth is a ScaledMetric, padding(_:) adds more space when the Label uses a larger text size.

Step 5

With the ScaledMetric variable padding, all the Dynamic Type variants now have padding between the leaf symbol and the edge of the Capsule shape in the background.

A grid of iPhone simulators, each containing two purple capsule shapes. The first capsule has a leaf symbol and the word, chives. The second capsule has a leaf symbol and the words, fern-leaf lavender. From the simulator in the upper-left to lower-right, the size of the text and the space between the text and the edge of the capsule increases progressively.
Next
Layering content
Define views in an overlay or background to adapt their layout to the primary content.


View layout
Layering content
Define views in an overlay or background to adapt their layout to the primary content.

Designs that layer content often specify that some content stays within the bounds of other content, or maintains a specific margin around that content. You can define these relationships between views with overlay and background modifiers. For example, if your design includes a graphic that provides contrast behind some text, you can define a layout so that the graphic adapts its size and position as the text updates. You can wrap text to fit within the width of another view by defining the text in a background or overlay of that other view.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Define an overlay
When you arrange content on the z-axis, you can use a ZStack or an overlay or background modifier, like overlay(alignment:content:) or background(_:in:fillStyle:), respectively. A ZStack sizes each view based on the available space, without consideration for the other views in the stack. To specify that the size of some content depends on the size of other content, define this secondary content inside one of the overlay or background modifiers.

This example presents a photo with a block of text over the lower portion of the photo. To improve readability of the text without completely obscuring that portion of the photo, there’s a mostly transparent background behind the text. The text wraps to fit within the width of the photo. The text’s background sizes to fit around the text. The CaptionedPhoto view arranges the image and provides the text to a Caption view in the image’s overlay(alignment:content:).

An exploded 3D illustration of a view hierarchy. The front layer contains the text, This photo is wider than it is tall. The next layer contains a partially transparent rounded rectangle that's a little taller and wider than the text layer. The back layer contains a photo of a pink flower that's a little wider and much taller than the other layers.
Step 1

CaptionedPhoto is a custom View that defines the layout of a photo and another custom Caption view, which defines the layout of the caption text that appears on top of the image.

Step 2

This view defines an assetName property to hold the name of the image asset.

Step 3

This view also defines a captionText property to contain the caption text that it eventually passes along to the Caption view.

Step 4

This Image view initializer retrieves a photo or graphic by name from your app and displays it.

Step 5

By default, an Image displays an image at its original size. The resizable(capInsets:resizingMode:) and scaledToFit() modifiers adjust this Image to fit within the available space.

The scaled image is the only view at the top level of this body, so the image determines the size of the CaptionedPhoto view. For more information about resizing images, see Fitting images into available space.

Step 6

The Caption custom view defines the text and its background.

Step 7

Defining the caption inside overlay(alignment:content:) declares that the caption belongs in front of the image. The size of the primary view limits the size of the overlay(alignment:content:) that modifies the primary view.

Specifying an alignment of bottom pushes the overlay(alignment:content:) modifier’s contents to the bottom center of the primary view.

Note

An overlay can be smaller than the view it modifies.

Step 8

Clipping the view to a RoundedRectangle rounds the corners of the image without changing its size or position.

Experiment

Change the cornerRadius value to a larger number to see its effect on the photo’s corners.

Step 9

This padding(_:_:) puts some space between all four edges of the photo and its containing view.

Experiment

Delete the padding(_:_:) modifier to see how that changes the layout. The padding modifier also appears twice in the Caption view. Remove each of those as well to see how their absence affects the layout.

CaptionedPhoto.swift
import SwiftUI


struct CaptionedPhoto: View {
    let assetName: String
    let captionText: String
    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .overlay(alignment: .bottom) {
                Caption(text: captionText)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            .padding()
    }
}


struct Caption: View {
    let text: String
    var body: some View {
        Text(text)
            .padding()
            .background(Color("TextContrast").opacity(0.75),
                        in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            .padding()
    }
}


struct CaptionedPhoto_Previews: PreviewProvider {
    static let landscapeName = "Landscape.jpeg"
    static let landscapeCaption = "This photo is wider than it is tall."
    static let portraitName = "Portrait.jpeg"
    static let portraitCaption = "This photo is taller than it is wide."
    static var previews: some View {
        CaptionedPhoto(assetName: portraitName,
                       captionText: portraitCaption)
        CaptionedPhoto(assetName: landscapeName,
                       captionText: landscapeCaption)
        .preferredColorScheme(.dark)
        CaptionedPhoto(assetName: landscapeName,
                       captionText: landscapeCaption)
        .preferredColorScheme(.light)
    }
}

Preview
A photo of a pink flower. Over the bottom of the photo is some text on a partially transparent contrasting background. The text is, This photo is wider than it is tall.
Section 2
Define a background
The overlay(alignment:content:) on the CaptionedPhoto contains a Caption view to display the caption text.

The Caption view uses the background(_:in:fillStyle:) modifier to place a shape behind the text that partially obscures any content behind it — in this example, the photo — to provide higher contrast for the text.

A photo of a pink flower. Over the bottom of the photo is some text on a partially transparent contrasting background. The text is, This photo is wider than it is tall.
Step 1

This padding(_:_:) modifier adds some space between the words and the edges of the contrasting background underneath. The structure of the code matches the visual appearance of the view — the padding is between the text and the background.

Important

Choose carefully how to combine padding with an overlay or background modifier. If you pad the primary view before modifying it with the overlay or background, the system uses the size of the padded primary view to calculate the placement of the secondary view. Apply the padding after the overlay or background to put a little space around the view that includes both layers.

Step 2

A background modifier like background(_:in:fillStyle:) is similar to an overlay modifier, in that its content bases its size on the size of the view it modifies. However, a background modifier puts its contents behind the view it modifies, rather than in front.

Step 3

To provide high contrast whether or not people use Dark Mode, this background(_:in:fillstyle:) modifier uses a custom color with partial opacity.

The TextContrast color set in this project’s asset catalog defines separate color values for light and dark appearances.

Step 4

RoundedRectangle, as a Shape, accepts whatever size its containing view proposes.

In this case, the background(_:in:fillstyle:) modifier creates that containing view, and any background modifier determines its size from the view it modifies. This results in a RoundedRectangle that is the same size as the padding around the Text view.

Step 5

This additional padding(_:_:) around the background adds space between the outside of the Caption view and the container it appears inside; in this case, CaptionedPhoto is the containing view.

CaptionedPhoto.swift
import SwiftUI


struct CaptionedPhoto: View {
    let assetName: String
    let captionText: String
    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .overlay(alignment: .bottom) {
                Caption(text: captionText)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            .padding()
    }
}


struct Caption: View {
    let text: String
    var body: some View {
        Text(text)
            .padding()
            .background(Color("TextContrast").opacity(0.75),
                        in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            .padding()
    }
}


struct CaptionedPhoto_Previews: PreviewProvider {
    static let landscapeName = "Landscape.jpeg"
    static let landscapeCaption = "This photo is wider than it is tall."
    static let portraitName = "Portrait.jpeg"
    static let portraitCaption = "This photo is taller than it is wide."
    static var previews: some View {
        CaptionedPhoto(assetName: portraitName,
                       captionText: portraitCaption)
        CaptionedPhoto(assetName: landscapeName,
                       captionText: landscapeCaption)
        .preferredColorScheme(.dark)
        CaptionedPhoto(assetName: landscapeName,
                       captionText: landscapeCaption)
        .preferredColorScheme(.light)
    }
}

Preview
A photo of a pink flower. Over the bottom of the photo is some text on a partially transparent contrasting background. The text is, This photo is wider than it is tall.
Next
Choosing the right way to hide a view
Control whether a view exists, and how that affects the overall layout.


View layout
Choosing the right way to hide a view
Control whether a view exists, and how that affects the overall layout.

If your design has views that aren’t always relevant, you have a choice about how their absence affects the overall layout. You can lay out all the other content as if the view doesn’t exist, then update the position of the other content when the view becomes visible. Or, you can reserve space for the view regardless of whether it’s visible, so that when it becomes visible, none of the other content needs to move to accommodate it.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Conditionally removing a view
Your design might have a login screen that doesn’t show an error message the first time it appears, but adds an error message after someone mistypes their password. The user name and password fields shouldn’t shift position depending on whether the error message is visible. Use an opacity(_:) modifier with a value of 0 so that the layout accounts for the error message whether or not it’s visible. You can also use this strategy for removing a view that doesn’t affect other views’ placement, like a view inside an overlay(alignment:content:) modifier.

Two wireframes of a login screen. Each screen has user name and password fields, and login button. The second screen also has an error message between the password field and login button. The data entry fields and button are in the same positions on both screens. 
Or, you might have an order Form that displays a second set of address fields if a person chooses not to use the same address for their shipping and billing addresses. For content like address fields that people might need to scroll past, use an if statement to only make room for the content when it’s visible, and shift other content as it appears and disappears.

If you need to reserve space in a layout based on the measurement of a view, but never want to show that view, you can use the hidden() modifier.

VoiceOver and gesture recognizers also ignore a view that you remove in any of these ways.

To show the differences between these approaches, this example uses a sequence of train cars. Each train has three views — a front, middle, and rear section — and uses the train car symbols from SF Symbols. For a long train, the front, middle, and rear car all appear. For a shorter train, the middle car doesn’t appear. The code that defines each train uses a different technique to omit the middle car.

A train with three train cars, rear, middle, and front.
Step 1

In these examples, the longerTrain property tracks whether to show or hide the middle train car.

In a full app, the data determining whether to hide a view might be a Binding, or an Environment value.

Step 2

The first train uses if, a conditional clause, to control the middle car. When longerTrain is true, the middle car is part of the train. When longerTrain is false, the middle car doesn’t exist, and the other cars are closer together.

You can also use an else clause the same way. The contents of the else clause only exist when the condition is false.

Step 3

The second train uses the opacity(_:) modifier to control the visibility of the middle car. When longerTrain is true, the middle car is part of the train, and it looks just like the previous conditional example. But when longerTrain is false, the middle car still takes up space in this train.

Use an opacity modifier when you don’t want other content to shift around as the view appears or disappears.

OpacityTrain.swift
import SwiftUI
struct OpacityTrain: View {
    var longerTrain: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "train.side.rear.car")
                Image(systemName: "train.side.middle.car")
                    .opacity(longerTrain ? 1 : 0)
                Image(systemName: "train.side.front.car")
            }
            Divider()
        }
    }
}


struct OpacityTrain_Previews: PreviewProvider {
    static var previews: some View {
        OpacityTrain(longerTrain: true)
        OpacityTrain(longerTrain: false)
    }
}

Preview
A train with three train cars close together, rear, middle, and front. An arrow points from this train to a second train. The second train has only rear and front train cars, with a gap between them.



View layout
Organizing and aligning content with stacks
Create dynamic alignments that adapt to data and environment changes using stacks.

When you have information to communicate that draws from a changeable data source that includes text and images, it’s important to align the content in a way that can adapt. This tutorial walks through using stacks to align content in rows and columns. It also uses stacks to create graphic elements that help organize information.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Manage related data with a view model
The first step in defining a view is to identify the data that the view displays. This view layout displays the details of an upcoming event, including the event’s name, date, and location. It also includes an icon indicating the type of event.

To organize that related data into a view model, this sample defines a custom structure.

A graphic containing a gift icon and the title Buy Daisies. Below the title are two additional lines of text, June 7 and Flower Shop. The background of the graphic is a pale teal rounded rectangle with a darker teal stripe across the top.
Step 1

This Event struct defines all the data for the event. The date is a Date value rather than a formatted String so the view can specify the date format. The symbol property is the name of an SF Symbol for the EventTile to display.

Step 2

The EventTile gets all the data for a specific instance from the Event structure in the tile’s event property.

Step 3

Three different parts of the EventTile view need to use the height of the top stripe, so it’s also a property outside of the body.

This is the only constant that specifies a dimension in this layout. All the other dimensions of this view depend on the data in the Event and semantic values in modifiers, such as font(_:).

EventTile.swift
import SwiftUI


struct Event {
    let title: String
    let date: Date
    let location: String
    let symbol: String
}


struct EventTile: View {
    let event: Event
    let stripeHeight = 15.0
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: event.symbol)
                .font(.title)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                Text(
                    event.date,
                    format: Date.FormatStyle()
                        .day(.defaultDigits)
                        .month(.wide)
                )
                Text(event.location)
            }
        }
        .padding()
        .padding(.top, stripeHeight)
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .opacity(0.3)
                Rectangle()
                    .frame(maxHeight: stripeHeight)
            }
            .foregroundColor(.teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
    }
}


struct EventTile_Previews: PreviewProvider {
    static let event = Event(title: "Buy Daisies", date: .now, location: "Flower Shop", symbol: "gift")
    
    static var previews: some View {
        EventTile(event: event)
    }
}

Preview
A graphic containing a gift icon and the title Buy Daisies. Below the title are two additional lines of text, June 7 and Flower Shop. The background of the graphic is a pale teal rounded rectangle with a darker teal stripe across the top.
Section 2
Define a view with nested stacks
After you define a data model, you can create views to display that data, and organize those views with stacks and alignment.

A VStack arranges the text in a column, and an HStack aligns the icon with the title text.

A graphic containing a gift icon and the title Buy Daisies. Below the title are two additional lines of text, June 7 and Flower Shop. The background of the graphic is a pale teal rounded rectangle with a darker teal stripe across the top.
Step 1

The leading alignment on the VStack overrides the stack’s default center alignment.

Step 2

The Text initializer init(_:format:) formats a date.

This initializer automatically accounts for environment-specific conditions, like the current calendar and locale.

Step 3

The title font makes the title text and the gift image more prominent than any content in the default body font.

The precise font size and weight depend on the environment, including the user’s current Dynamic Type settings.

Experiment

Customize this symbol with the techniques in Configuring and displaying symbol images in your UI.

Step 4

The firstTextBaseline alignment in the HStack aligns the gift image with the title text.

Note

If you’re arranging text and a symbol that only need to align with each other, it’s better to use a Label. Label aligns its icon to the first baseline of its title by default, and adapts to the context in which it appears.

EventTile.swift
import SwiftUI


struct Event {
    let title: String
    let date: Date
    let location: String
    let symbol: String
}


struct EventTile: View {
    let event: Event
    let stripeHeight = 15.0
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: event.symbol)
                .font(.title)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                Text(
                    event.date,
                    format: Date.FormatStyle()
                        .day(.defaultDigits)
                        .month(.wide)
                )
                Text(event.location)
            }
        }
        .padding()
        .padding(.top, stripeHeight)
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .opacity(0.3)
                Rectangle()
                    .frame(maxHeight: stripeHeight)
            }
            .foregroundColor(.teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
    }
}


struct EventTile_Previews: PreviewProvider {
    static let event = Event(title: "Buy Daisies", date: .now, location: "Flower Shop", symbol: "gift")
    
    static var previews: some View {
        EventTile(event: event)
    }
}

Preview
A graphic containing a gift icon and the title Buy Daisies. Below the title are two additional lines of text, June 7 and Flower Shop. The background of the graphic is a pale teal rounded rectangle with a darker teal stripe across the top.
Section 3
Add a background with layered shapes
To indicate that all of this information represents a single event, a background(alignment:content:) modifier contains a ZStack of Shape views.

This defines a background that adapts to the size of the information the main view displays.

A graphic containing a gift icon and the title Buy Daisies. Below the title are two additional lines of text, June 7 and Flower Shop. The background of the graphic is a pale teal rounded rectangle with a darker teal stripe across the top.
Step 1

To make the background bigger than the HStack that encloses all the content, this padding(_:_:) modifier adds some space on all four edges of the view.

Step 2

This second use of the same padding(_:_:) modifier on the main content adds space for the stripe at the top of the view, in addition to the space defined by the previous padding(_:_:) modifier.

Step 3

A background(alignment:content:) modifier bases its size on the size of the view it modifies, and puts its contents behind that view.

Step 4

This top-aligned ZStack layers the brighter stripe Rectangle over the Rectangle that fills the background of the EventTile.

The stack’s alignment puts the stripe at the top of the EventTile.

Step 5

This frame(width:height:alignment:) modifier specifies the height of the stripe, leaving its width dependent on its containing view.

Specifying a frame on a decorative Shape like this stripe is a common pattern.

Note

Specifying frames on text and controls may interfere with the sizing behavior and usability of those views. To learn best practices for adjusting the size of various views, see Maintaining the adaptable sizes of built-in views.

Step 6

Applying the teal foregroundColor(_:) to the stack specifies the color for both of the Rectangle views in the stack.

Step 7

Clipping the final view with clipShape(_:style:) and the RoundedRectangle shape applies the rounded corners only to the outermost edges, rather than rounding the corners of each view.

This avoids rounding the bottom corners of the stripe Rectangle.

EventTile.swift
import SwiftUI


struct Event {
    let title: String
    let date: Date
    let location: String
    let symbol: String
}


struct EventTile: View {
    let event: Event
    let stripeHeight = 15.0
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: event.symbol)
                .font(.title)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                Text(
                    event.date,
                    format: Date.FormatStyle()
                        .day(.defaultDigits)
                        .month(.wide)
                )
                Text(event.location)
            }
        }
        .padding()
        .padding(.top, stripeHeight)
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .opacity(0.3)
                Rectangle()
                    .frame(maxHeight: stripeHeight)
            }
            .foregroundColor(.teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
    }
}


struct EventTile_Previews: PreviewProvider {
    static let event = Event(title: "Buy Daisies", date: .now, location: "Flower Shop", symbol: "gift")
    
    static var previews: some View {
        EventTile(event: event)
    }
}

Preview
A graphic containing a gift icon and the title Buy Daisies. Below the title are two additional lines of text, June 7 and Flower Shop. The background of the graphic is a pale teal rounded rectangle with a darker teal stripe across the top.



View layout
Adjusting the space between views
Specify the alignment and spacing of your content.

As you define the views that display information, you can adjust the layout by declaring where any extra space should go. Depending on how you want your layout to adapt, you may choose different tools. Some of the tools for managing the space between views are themselves views, like Spacer. There are also view modifiers that affect the space adjacent to a view, like padding(_:_:). In some cases, you affect a layout by providing a non-default value as a parameter of a view or modifier.

Project files
Xcode 14 or later
Section 1
Define your content
To show some different strategies for changing the spacing between views, this example uses a sequence of train cars. Each train has three views — a front, middle, and rear section — and uses the train car symbols from SF Symbols. These examples use an HStack to show horizontal spacing. The same principles apply on the vertical axis and to other stack and grid views in SwiftUI.

Side views of a rear train car, a middle train car, and a front train car.
Many of these container views include some negative space by default, so set up your content and a PreviewProvider first to see how the defaults look before you customize the spacing.

Step 1

This custom view defines an Image view that displays an SF Symbol of a train car, with a pink background to show the extent of the view.

You can define your own custom views so that you can have similar views in multiple places without having to specify the same modifiers and parameters in each place.

Experiment

Try changing the color of the background(_:ignoresSafeAreaEdges:) to another color, and see the color of the background change on all the train cars.

Step 2

Here’s an example of that custom TrainCar view in use. This view declaration only specifies which part of the train it represents. The TrainCar structure defines the Image view with the corresponding symbol and adds a background.

Step 3

This HStack contains three TrainCar views - front, middle, and rear - to form a train. The code doesn’t add any custom space or padding to the HStack or the TrainCar views, but there’s still a little space between the frames of the train cars.

An HStack, like many of SwiftUI’s built-in collection views, puts some spacing between its subviews by default.

DefaultSpacing.swift
import SwiftUI


struct DefaultSpacing: View {
    var body: some View {
        Text("Default Spacing")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}


struct DefaultSpacing_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DefaultSpacing()
        }
    }
}

Preview
Side views of three train cars with a pink rectangle behind each one. There are gaps between the rectangles.
Section 2
Customize a container's spacing
The default spacing of an HStack isn’t right for all layouts. You can specify a constant spacing between a stack’s subviews, spacing that scales with Dynamic Type, or no spacing at all.

A wireframe representing a row of images with gaps between them and lines measuring those gaps.
Step 1

The spacing parameter of an HStack customizes the spacing between its views. This value of 20 puts 20 points of space between the front and middle TrainCar views and 20 points of space between the middle and rear TrainCar views, instead of the default spacing.

Step 2

Because these train cars are SF symbols, their size changes when the current dynamicTypeSize changes. This train’s spacing adjusts proportionally. In this HStack, the value for the spacing parameter is the trainCarSpace property of the ScaledSpacing view.

Experiment

Adjust the Dynamic Type slider in the Canvas Device Settings to see how the train cars and spacing in the preview change.

Step 3

The ScaledMetric property wrapper configures the trainCarSpace property to change in proportion to the current body font size.

Step 4

Using the value of 0 for the spacing parameter here removes all of the space between the views. In this HStack, the train cars are right next to each other.

ZeroSpacing.swift
import SwiftUI


struct ZeroSpacing: View {
    var body: some View {
        Text("Zero Spacing")
        HStack(spacing: 0) {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}


struct ZeroSpacing_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZeroSpacing()
        }
    }
}

Preview
Side views of three train cars with a pink rectangle behind the train.
Section 3
Add padding around subviews
You can add padding to the outer edges of a view to put some space between that view and any neighboring views, or to the edge of a window or scene.


Step 1

padding(_:_:) without any parameters puts space around all four edges. The size of the default padding varies, depending on attributes of the view and the environment where the view appears.

Step 2

This example pads the leading edge of a train car, but not the other edges, by specifying a set that contains only leading.

Step 3

This example defines a specific amount of padding in the length parameter.

You can also use a ScaledMetric to adjust the spacing in response to font changes.

Step 4

The effect of the padding modifier depends on which view it modifies.

Applying the padding(_:_:) modifier to the stack that contains the TrainCar views puts padding around the edges of the stack instead of between the train cars.

PaddingTheContainer.swift
import SwiftUI


struct PaddingTheContainer: View {
    var body: some View {
        Text("Padding the Container")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        .padding()
        .background(Color("customBlue"))
        TrainTrack()
    }
}


struct PaddingTheContainer_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PaddingTheContainer()
        }
    }
}

Preview
Side views of three train cars with a pink rectangle behind each one. Behind the whole train is a larger blue rectangle.
Section 4
Add a view to create space
Besides modifying a content view to create space, you can also create space by adding an invisible view that modifies your layout without displaying any content.


Step 1

This Spacer() between views pushes the content views as far apart as possible.

You can specify a minimum width for each Spacer, or let it squish all the way to zero if the adjacent content needs all the space.

Experiment

Change to a landscape orientation in the Canvas Device Settings or choose a different size device for previews to see how the width of the device changes the layout.

Step 2

This layout specifies an amount of space that depends on the size of a view by using the opacity modifier to create an invisible version of that view to take up the correct amount of space.

Step 3

A ZStack adapts to the size of its largest view, so the invisible view in this stack creates a visual appearance like padding around the middle train car.

StackingPlaceholder.swift
import SwiftUI


struct StackingPlaceholder: View {
    var body: some View {
        Text("Stacking with a Placeholder")
        HStack {
            TrainCar(.rear)
            ZStack {
                TrainCar(.middle)
                    .font(.largeTitle)
                    .opacity(0)
                    .background(Color("customBlue"))
                TrainCar(.middle)
            }
            TrainCar(.front)            
        }
        TrainTrack()
    }
}


struct StackingPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StackingPlaceholder()
        }
    }
}

Preview
Side views of three train cars with a pink rectangle behind each one. The middle train car has a blue border around the pink rectangle.



State and data flow
Driving changes in your UI with state and bindings
Indicate data dependencies in a view using state, and share those dependencies with other views using bindings.

The user interface of a SwiftUI app is a composition of views that form a view hierarchy. Each view has a dependency on some data. As that data changes, either due to external events or because of actions taken by a person using the app, SwiftUI automatically updates the view to reflect those changes.

This sample shows examples of using State variables to indicate data dependencies, and sharing data with other views using the Binding property wrapper.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Separate properties and imperative code from the view
When a view needs to manage more than a single piece of state data, it can be helpful to manage that data in a separate view-specific structure. This approach helps make the declarative interface code of a view more readable by moving properties and imperative code outside of the view. It also helps make unit testing state changes easier to implement.

This sample app displays a collection of cooking recipes. A person using the app can view the details of a recipe and add new ones. To add a recipe, the sample presents the custom view RecipeEditor, which needs three pieces of state data: a recipe, a flag indicating whether to save the changes, and a flag indicating whether to present the RecipeEditor view.

The sample app separates its state data and imperative code from RecipeEditor by defining a structure, RecipeEditorConfig.

Step 1

The structure RecipeEditorConfig stores the state data that the RecipeEditor view needs.

To trigger state changes that happen in the RecipeEditor view, RecipeEditorConfig provides mutating functions that update the data to reflect a new state.

Step 2

The method presentAddRecipe(sidebarItem:) changes the state of the view to indicate that its editing a new recipe.

Note

The app calls this method when a person taps the Add Recipe button.

Step 3

This method creates an empty recipe as the recipe to edit.

The static method emptyRecipe() creates a new instance of Recipe, setting its properties to the default values of a new recipe.

Step 4

In addition to the default values that emptyRecipes() sets, presentAddRecipe(sidebarItem:) sets the recipe’s isFavorite and collections properties based on the selected sidebar item.

By setting the isFavorite and collections properties, the new recipe automatically appears in the appropriate list of recipes after saving the recipe.

Step 5

presentAddRecipe(sidebarItem:) sets the shouldSaveChanges flag to false because the person using the app hasn’t indicated that they want to save the changes yet.

Step 6

This method sets the isPresented flag to true to tell SwiftUI to display the editor view.

Note

Keeping reading to learn how the recipe editor appears based on the isPresented value.

Step 7

The method presentEditRecipe(_:) is similar to presentAddRecipe(sidebarItem:), but for editing an existing recipe.

Step 8

Instead of creating an empty recipe like presentAddRecipe(sidebarItem:) does, presentEditRecipe(_:) receives the recipe to edit as a parameter and sets recipe to the incoming recipe.

The RecipeEditorConfig supports two other mutating methods that trigger state changes in the editor while also separating imperative code from declarative interface code: done() and cancel().

Step 9

The done() method indicates that the editor should save changes made to the recipe, and dismiss the RecipeEditor view.

The method sets shouldSaveChanges to true to indicate that the app should save changes made to the recipe. It also sets isPresented to false, which tells SwiftUI to dismiss the editor view.

Step 10

The cancel() method is similar to done(), but it sets shouldSaveChanges to false, telling the app to disregard the changes made to the recipe.

The method also sets isPresented to false, which tells SwiftUI to dismiss the editor view.

RecipeEditorConfig.swift
import Foundation


struct RecipeEditorConfig {
    var recipe = Recipe.emptyRecipe()
    var shouldSaveChanges = false
    var isPresented = false
    
    mutating func presentAddRecipe(sidebarItem: SidebarItem) {
        recipe = Recipe.emptyRecipe()


        switch sidebarItem {
        case .favorites:
            // Associate the recipe to the favorites collection.
            recipe.isFavorite = true
        case .collection(let name):
            // Associate the recipe to a custom collection.
            recipe.collections = [name]
        default:
            // Nothing else to do.
            break
        }
            
        shouldSaveChanges = false
        isPresented = true
    }
    
    mutating func presentEditRecipe(_ recipeToEdit: Recipe) {
        recipe = recipeToEdit
        shouldSaveChanges = false
        isPresented = true
    }
    
    mutating func done() {
        shouldSaveChanges = true
        isPresented = false
    }
    
    mutating func cancel() {
        shouldSaveChanges = false
        isPresented = false
    }
}

No Preview
Section 2
Bind the view to its state data
With a structure in place that contains the data that the recipe editor needs, and methods that change the state of the editor, look at the RecipeEditor view to see how it uses RecipeEditorConfig.

Step 1

RecipeEditor is a structure that conforms to the View protocol.

Step 2

The structure declares the binding variable config of type RecipeEditorConfig, which contains the state data that the view uses to determine its appearance.

Important

The Binding property wrapper provides a two-way, read-write binding to data that the view needs. However, RecipeEditor doesn’t own the data. Instead, another view creates and owns the instance of RecipeEditorConfig that RecipeEditor binds to and uses.

Step 3

RecipeEditor contains RecipeEditorForm, which displays the input fields needed to edit recipe data.

Important

RecipeEditor passes the binding variable config to RecipeEditorForm. It passes the variable as a binding, indicated by prefixing the variable name config with the $ symbol. Because RecipeEditorForm receives config as a binding, the form can read and write data to config.

Step 4

The editor displays a Cancel button in its toolbar.

When a person taps the Cancel button, its action calls the mutating method cancel() defined in RecipeEditorConfig, which sets shouldSaveChanges to false and isPresented to false.

Step 5

The editor also displays a Save button that, when a person taps it, calls the mutating done() method, which sets shouldSaveChanges to true and isPresented to false, telling the app to save any changes made to the recipe and dismiss the editor view.

Important

Settings shouldSaveChanges and isPresented in the cancel() and done() methods make the view code easier to read because each button’s action only needs one line of code. The button actions could’ve explicitly set config.saveConfig and config.isPresented, but keeping imperative code in an action to a minimum helps make the declarative interface code of the view more readable and easier to maintain.

RecipeEditor.swift
import SwiftUI


struct RecipeEditor: View {
    @Binding var config: RecipeEditorConfig
    
    var body: some View {
        NavigationStack {
            RecipeEditorForm(config: $config)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(editorTitle)
                    }
                    
                    ToolbarItem(placement: cancelButtonPlacement) {
                        Button {
                            config.cancel()
                        } label: {
                            Text("Cancel")
                        }
                    }
                    
                    ToolbarItem(placement: saveButtonPlacement) {
                        Button {
                            config.done()
                        } label: {
                            Text("Save")
                        }
                    }
                }
            #if os(macOS)
                .padding()
            #endif
        }
    }
    
    private var editorTitle: String {
        config.recipe.isNew ? "Add Recipe" : "Edit Recipe"
    }
    
    private var cancelButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .cancellationAction
        #else
        .navigationBarLeading
        #endif
    }
    
    private var saveButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .confirmationAction
        #else
        .navigationBarTrailing
        #endif
    }
}

Preview
A screenshot of the recipe editor with the save button highlighted.
Section 3
Create a state variable in another view
The RecipeEditor view has a binding to an instance of RecipeEditorConfig. The editor can read and write the data but it doesn’t own the recipe data. Instead, the view ContentListView creates and owns the data, and SwiftUI manages that data for the lifespan of the content list view.

Step 1

ContentListView is a custom view that conforms to the View protocol and displays a list of recipes.

ContentListView is also responsible for displaying the recipe editor when a person wants to add a recipe, making this view the ideal place to create an instance of RecipeEditorConfig.

Step 2

The view defines the private state variable recipeEditorConfig, of type RecipeEditorConfig.

Important

The recipeEditorConfig declaration includes the attribute for the State property wrapper, which tells SwiftUI to create and manage the instance of RecipeEditorConfig. Each time view state changes, that is, data that recipeEditorConfig contains changes, SwiftUI reinitializes the view, reconnects the RecipeEditorConfig instance to the view, and rebuilds the view defined in the computed body property, which reflects the current state of the data. For more information, see Model data.

Step 3

This view also displays an Add Recipe button in its toolbar.

The Add Recipe button appears as a button with a plus sign as its label.

Step 4

When a person taps the Add Recipe button, the button’s action calls the mutating method presentAddRecipe(sidebarItem:), which changes the data contained in recipeEditorConfig.

Recall that presentAddRecipe(sidebarItem:) creates an empty recipe and sets its isFavorite and collections property values based on the selected sidebar item. The method also sets shouldSaveChanges to false and isPresented to true. Keeping this imperative code outside of the view helps make the declarative code of the view easier to understand and maintain.

Note

When presentAddRecipe(sidebarItem:) changes the data in recipeEditorConfig, SwiftUI reinitializes the ContentListView instance and reconnects recipeEditorConfig to the instance that it’s managing. SwiftUI then rebuilds the view from its computed body property so that the view reflects the current state of the data.

Step 5

After calling presentAddRecipe(sidebarItem:), isPresented is true, which tells SwiftUI to display a sheet that contains the recipe editor.

The Boolean value recipeEditorConfig.isPresented determines whether to present the sheet that contains the RecipeEditor view. When the value changes from false to true, the sheet presents a modal view containing RecipeEditor. When the value changes from true to false, the sheet dismisses the modal view.

Note

The modifier sheet(isPresented:onDismiss:content:) receives a binding as indicated by the dollar sign ($) prefix. This binding lets the sheet read and write to the property. For instance, when a person dismisses the sheet by swiping it downward, the sheet sets recipeEditorConfig.isPresented to false. This change causes SwiftUI to reinitialize and rebuild the view. And because isPresented is now false, the sheet no longer appears.

Step 6

The sheet contains RecipeEditor, a custom view that displays a form containing input fields that let a person change the data of a recipe.

RecipeEditor receives a binding to recipeEditorConfig — as indicated by the dollar sign ($) prefix — which makes it possible for the editor to retrieve and make changes to data contained in recipeEditorConfig. This includes changing recipe data and triggering state changes.

Step 7

When the value of isPresented changes from true to false, the sheet calls its onDismiss action, which calls the didDismissEditor method.

Note

The sheet also calls onDismiss when isPresented changes from true to false in the cancel() and done() methods that RecipeEditorConfig defines. The sheet is able to detect the value change because it has a binding to the recipeEditorConfig.isPresented property.

Step 8

This view implements the didDismissEditor method, which saves the changes a person makes to the recipe if recipeEditorConfig.shouldSaveChanges is true; otherwise, the method disregards the changes.

Note

RecipeEditorConfig concerns itself with RecipeEditor and only that view, which is why ContentListView implements the didDismissEditor method instead of RecipeEditorConfig. This approach keeps the areas of concern separate.

ContentListView.swift
import SwiftUI


struct ContentListView: View {
    @Binding var selection: Recipe.ID?
    let selectedSidebarItem: SidebarItem
    @EnvironmentObject private var recipeBox: RecipeBox
    @State private var recipeEditorConfig = RecipeEditorConfig()


    var body: some View {
        RecipeListView(selection: $selection, selectedSidebarItem: selectedSidebarItem)
            .navigationTitle(selectedSidebarItem.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        recipeEditorConfig.presentAddRecipe(sidebarItem: selectedSidebarItem)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $recipeEditorConfig.isPresented,
                           onDismiss: didDismissEditor) {
                        RecipeEditor(config: $recipeEditorConfig)
                    }
                }
            }
    }
    
    private func didDismissEditor() {
        if recipeEditorConfig.shouldSaveChanges {
            if recipeEditorConfig.recipe.isNew {
                selection = recipeBox.add(recipeEditorConfig.recipe)
            } else {
                recipeBox.update(recipeEditorConfig.recipe)
            }
        }
    }
}

No Preview



State and data flow
Creating a custom input control that binds to a value
Provide interactions that are unique to your app with custom controls that bind to a value.

SwiftUI provides input controls like Slider, TextField, and many others that bind to a value and can change the value as a person’s interacts with the control. But every app is different. You may find that you need a custom control that provides behavior unique to your app.

SwiftUI provides the building blocks you need to create a custom input control for your app. This tutorial walks through an example of one such control, a rating control. The sample app uses this control to let people rate recipes from 1 to 5 stars.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Design a custom control
Before implementing a custom control, ask yourself what data does the control need, what does it do with that data, and how it does it represent that data visually within the app. The sample app, for instance, needs an Int property that represents the rating of a recipe. The control needs to be able to change the value of this property. And because the control shows the rating of a recipe, it needs to display a set of stars that reflects the rating value; for instance, the control displays five stars when the rating value is 5.

Step 1

The sample defines the custom control as a structure named StarRating.

This structure conforms to the View protocol because the control appears as part of the app’s user interface.

Step 2

The structure defines a Binding variable named rating, which stores the rating of a recipe.

By defining rating as a binding variable, StarRating can read and write the value even though another view is responsible for creating the value.

Step 3

The private constant maxRating stores the highest rating possible that a person can give a recipe.

Step 4

Like all other SwiftUI views, StarRating implements the required computed property body.

Note

Every SwiftUI view must implement body to provide the contents of the view.

Step 5

The HStack displays the rating stars in a horizontal line.

Step 6

Inside the HStack, the control uses a ForEach structure to display the number of stars indicated by the maxRating constant.

ForEach iterates through a collection of data defined as a range of Int instances, 1 to 5.

Important

The id parameter is of type ID, which is Hashable. The ForEach structure uses this parameter to identify the data, that is, the integer values 1 through 5. The parameter value is the identity key path \.self, which specifies an Int instance for each integer. Because Int is hashable, using this key path satisfies the requirements of the ForEach initializer method init(_:id:content:). And because the data is an increasing range of integers that will never have duplicate values, it’s okay to use each integer value as its identifier.

Step 7

The control displays a star using an instance of Image.

The sample displays an image of a star using the initializer method init(systemName:). This method creates an image view that displays a system symbol image. Symbol images like star come from SF Symbols, a library of iconography that you can use in your app.

Experiment

Change the symbol from a star to another symbol such as circle.

Step 8

The control displays a filled star when the integer value is less than or equal to the rating value and an empty star when the integer value is greater than rating, so the control applies the symbolVariant(_:) modifier to the Image instance.

Note

To determine which SymbolVariants to apply, fill or none, the control uses a ternary conditional operator. This operator takes three parts, which takes the form of question ? answer1 : answer2. For more information, see Ternary Conditional Operator.

Step 9

The control set the color of the stars using the foregroundColor(_:) view modifier.

Experiment

Change the color of the stars by replacing accentColor with a different color, such as yellow.

StarRating.swift
import SwiftUI


struct StarRating: View {
    @Binding var rating: Int
    private let maxRating = 5


    var body: some View {
        HStack {
            ForEach(1..<maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .symbolVariant(value <= rating ? .fill : .none)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        if value != rating {
                            rating = value
                        } else {
                            rating = 0
                        }
                    }
            }
        }
    }
}

Preview

Section 2
Make the control interactive
StarRating is able to display a set of stars to indicate the rating of a recipe. For instance, if the recipe’s rating is 4, the control displays four filled stars, followed by one empty star. To make StarRating interactive, it uses the onTapGesture(count:perform:) action.

Step 1

To make it possible for a person to interact with the rating control, StarRating adds the onTapGesture(count:perform:) action to each Image instance created in the ForEach loop.

The tap gesture performs the action defined in the closure when a person clicks or taps a star Image instance. The star indicates the rating that StarRating assigns to the recipe. For example, if a person taps the fourth star, the recipe’s rating is set to 4. Tap the fourth star again and StarRating resets the recipe’s rating to 0 or no stars.

Step 2

When the integer value isn’t equal to the rating value, the closure sets rating to the integer value, which indicates the new rating that the person assigns to the recipe.

By setting rating to the integer value, StarRating updates its appearance to show filled stars up to the number identified by value, followed by empty stars up to the number identified by maxRating.

Step 3

When the integer value is equal to the rating value, the closure resets the recipe’s rating to no stars by setting rating to 0.

StarRating displays five empty stars to indicate that the recipe has no rating.

StarRating.swift
import SwiftUI


struct StarRating: View {
    @Binding var rating: Int
    private let maxRating = 5


    var body: some View {
        HStack {
            ForEach(1..<maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .symbolVariant(value <= rating ? .fill : .none)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        if value != rating {
                            rating = value
                        } else {
                            rating = 0
                        }
                    }
            }
        }
    }
}

Preview

Section 3
Display the custom control in other views
StarRating is ready to go. It has the data it needs, it can apply changes to that data, and it can visually represent the current state of the data in the app’s user interface. The next step is to make use of the custom input control.

In the sample app, StarRating appears under the recipe title that appears in the recipe detail view.

Step 1

The structure RegularTitleView is a view that displays the title and subtitle of a recipe along with its rating.

Step 2

RegularTitleView defines a binding variable that stores a recipe received from another view.

This binding allows the view to read and write data to an instance of Recipe. However, the view isn’t the owner of the recipe. Another view in the sample is responsible for creating and owning the Recipe instance.

Step 3

The view shares a binding to the recipe’s rating property with the custom control StarRating, which allows the control to read and write to that property.

As a person interacts with the StarRating control, SwiftUI redraws the view to reflect the selected rating.

Important

The dollar sign ($) prefix on the variable name recipe indicates that the call is passing a binding to StarRating.

RegularTitleView.swift
import SwiftUI


struct RegularTitleView: View {
    @Binding var recipe: Recipe


    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .font(.largeTitle)
            StarRating(rating: $recipe.rating)
        }
        Spacer()
        Text(recipe.subtitle)
            .font(.subheadline)
    }
}


State and data flow
Defining the source of truth using a custom binding
Provide an alternative to a state variable by using a custom binding.

The most common way to define a source of truth that binds to other views in your app is to declare a state variable using the State property wrapper. However, there may be those rare occasions when the source of truth is dynamic and can’t be defined using the @State attribute. For instance, this sample app needs to retrieve a recipe as the source of truth using the recipe’s id. The app accomplishes this by creating a computed property that returns a custom binding.

To experiment with the code, download the project files and open the sample in Xcode.

Project files
Xcode 14 or later
Section 1
Specifying the source of truth
This sample app displays the details of a recipe in the custom view DetailView. The view only knows the recipe id, but not the recipe, so it uses the id to retrieve the recipe from the recipe box (a data store that contains all the recipes). Because the view needs to retrieve the recipe, it uses a custom binding as the source of truth of the recipe instead of declaring a state variable for the recipe.

Note

Using a custom binding is a useful feature of SwiftUI, but isn’t always the best option. Limit its use to use cases where using a state variable or object isn’t possible. In most cases, define the source of truth as either a State variable (for state local to the view) or StateObject (for shared data models) to let SwiftUI manage the value or object for you.

Step 1

To get the recipe value in the DetailView, this sample implements the computed property recipe instead of declaring a state variable.

The computed recipe property doesn’t return a Recipe. Instead, it returns a custom Binding of type Recipe. This allows the view to share the recipe as a source of truth with other views.

Step 2

A Binding provides read and write access to a value. To provide this access to the recipe value, the computed recipe property uses the init(get:set:) initializer method to create a binding.

Step 3

The binding’s get closure uses recipeId to retrieve a recipe from the data store recipeBox.

If the recipe no longer exists or can’t be found, the closure returns an empty recipe.

Step 4

In the set closure, the binding updates the recipe box with the new recipe value, updatedRecipe.

This update happens any time data changes in the binding’s recipe value; for instance, after a person changes the rating of the recipe.

Step 5

DetailView passes recipe to the RecipeDetailView view as a binding value, which allows the detail view to read and write to the recipe value.

Important

Because the computed property recipe returns a Binding, it isn’t necessary to include the dollar sign ($) prefix that’s required when passing a state variable as a binding. For state variables — variables defined with a State property wrapper — the dollar sign ($) prefix tells SwiftUI to pass the projectedValue, which is a Binding.

Step 6

The navigationTitle(_:) modifier accepts a string value not a binding to a string value, so the view passes the recipe binding’s wrappedValue.

A wrappedValue is the underlying value referenced by the binding. Since the computed recipe property returns a binding, its wrapped value is the actual recipe value. So recipe.wrappedValue.title gets the wrappedValue of the recipe binding, then it passes the title property of the recipe value to navigationTitle(_:).

DetailView.swift
import SwiftUI


struct DetailView: View {
    @Binding var recipeId: Recipe.ID?
    @EnvironmentObject private var recipeBox: RecipeBox
    @State private var showDeleteConfirmation = false
    
    private var recipe: Binding<Recipe> {
        Binding {
            if let id = recipeId {
                return recipeBox.recipe(with: id) ?? Recipe.emptyRecipe()
            } else {
                return Recipe.emptyRecipe()
            }
        } set: { updatedRecipe in
            recipeBox.update(updatedRecipe)
        }
    }


    var body: some View {
        ZStack {
            if recipeBox.contains(recipeId) {
                RecipeDetailView(recipe: recipe)
                    .navigationTitle(recipe.wrappedValue.title)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        RecipeDetailToolbar(
                            recipe: recipe,
                            showDeleteConfirmation: $showDeleteConfirmation,
                            deleteRecipe: deleteRecipe)
                    }
            } else {
                RecipeNotSelectedView()
            }
        }
    }
    
    private func deleteRecipe() {
        recipeBox.delete(recipe.id)
    }
}