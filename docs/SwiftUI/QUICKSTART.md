
Explore Xcode
Hello, SwiftUI
Get to know Xcode, Swift, and SwiftUI.

You’ll build Chat Prototype, a chat conversation using text views. The text and colors in the project are just suggestions, so feel free to make it your own by changing the words and style.

If you haven’t already installed Xcode, follow the directions in Meet Xcode.

Section 1
Create and explore a project
Start an iOS App project and explore the code that Xcode generates for you.

Swift and SwiftUI are designed to read like natural language. Swift is the programming language you use to write your app’s code. SwiftUI is a framework that provides views, controls, and layout structures for creating your app’s user interface.

Illustration of a phone screen with a globe above the words hello world.
Step 1

Launch Xcode. In the welcome window that appears, click Create New Project. (If Xcode is already running, you can choose File > New > Project.) In the following dialog, select the App template in the iOS tab and click Next.

Step 2

In the project settings dialog, enter “ChatPrototype” for the product name and “name.<yourname>” for the organization identifier (for example, “name.sophiesun”). Then, click Next.

Step 3

In the Save dialog, choose a location to save your project. Then, click Create.

Step 4

Read through the code that Xcode generates for your project. The names of many Swift elements are common English words.

Image, Text, and .imageScale all hint at how they create the interface.

Note

imageScale is in camel case: The words are glued together without spaces and each word after the first is capitalized.

Step 5

Look for the braces and parentheses in your code.

Parentheses usually have information related to the code immediately before them. Braces are like containers — they usually group multiple lines of code into one chunk.

Experiment

Try double-clicking an opening or closing brace or parenthesis.

Step 6

Look for indentation in your code.

You use indentation to reflect the code’s organization and make it more readable. However, code without any indentation still runs.

Step 7

Xcode colors different parts of your code according to their purpose; this is called syntax highlighting. Some things, such as struct, are keywords in Swift, while others, such as Image, are features of SwiftUI.

To change syntax highlighting colors, choose Editor > Theme. To customize a color theme or add your own, choose Xcode > Settings, then select the Themes tab.

Step 8

Find the text “Hello, world!” in the code. It’s colored red and surrounded by quotation marks.

Swift calls written language String.

Screenshot showing Swift code, with the text, Hello World, between quotation marks highlighted.
Section 2
Edit code and make mistakes
Change the code in the editor and see how the preview updates in response.

Xcode has features common to other text editors, like copy and paste, undo and redo, and text selection.

Illustration of the top half of the Chat Prototype app, showing a globe symbol over the text, knock knock.
Step 1

Change the text inside the quotation marks to a word or phrase of your choice.

Make sure not to delete the quotation marks themselves.

Note

You won’t see the preview until Xcode finishes downloading the iOS platform.

Step 2

Now, make a deliberate mistake. Delete the string inside the Text, including the quotation marks.

Notice the error banner in Xcode that popped up on the line of code you edited. When Xcode can’t understand what you wrote in the editor, you’ll see messages like this.

Step 3

Start to correct the error by typing one quotation mark inside the parentheses. The editor may automatically insert a second one for you; if so, delete the second one.

Sometimes you can cause temporary errors by putting the code into an invalid state as you type. The current error is a good example. Text needs you to supply a string for it to display, but you haven’t finished typing a string.

Step 4

Click the red icon at the head of the the error banner to expand details for both errors. The new error is “Unterminated string literal.” String literal is the kind of Swift String you’ve been working with — text inside quotation marks.

All languages have rules, including Swift. If you begin a string with a quotation mark but don’t close it with a second one, you’ve broken a rule about string literals. Notice that the closing parenthesis is now red, because Xcode guesses that the closing parenthesis is part of the string.

Step 5

Add a second quotation mark to fix the error.

The preview on the right now has no visible text — just a globe image. That’s because the text is an empty string, so there’s no text to display.

Step 6

Put your greeting string back in the Text view before you continue to the next section.

Your code is working again, and you’ve completed the first part of your conversation.

ContentView.swift
//
//  ContentView.swift
//  ChatPrototype
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Knock, knock!")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot showing a vertical arrangement of two items. At the top is a globe symbol. Below is the text, Knock knock.
Section 3
Use the library to add a Text view
In SwiftUI, a view is part of the interface of an app. Text is one example of a view.

Views are distinct from the data they display. Text is the view, and the String inside the parentheses is the data.

Illustration of the top half of the Chat Prototype app, showing the text, knock knock, then the text, who's there.
Step 1

Delete the line of code beginning with Image and the two lines below it. Then add a line below the Text view.

Step 2

Click the Add button (+) at the top of the project window, which opens the Library. You can also open the Library by choosing View > Show Library.

Use the Library for quick access to SwiftUI components, colors, and images, as well as other items you’ll use frequently when building an app. You can click and drag to position it. To dismiss the Library, press Escape or click anywhere else on the screen.

Step 3

Select the first icon below the search field to show the list of views.

Step 4

Type “text” in the field at the top to narrow your search. Then, from the list below, select Text. To insert it into your code, double-click it or press Return.

The new view has a placeholder string in a blue capsule, which is highlighted by default.

Step 5

Type to replace the selected text with a new message. Remember to include quotation marks.

ContentView.swift
//
//  ContentView.swift
//  ChatPrototype
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            Text("Knock, knock!")
            Text("Who's there?")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot showing a vertical arrangement of two items. At the top is the text, Knock knock. Below is the text, Who's there.
Section 4
Use code completion to add modifiers
Now that you have a pair of chat messages, use view modifiers to change their appearance and behavior.

Illustration of the top half of the Chat Prototype app, showing the text, knock knock, then the text, who's there. Each line of text is in a colored rectangle.
Step 1

Add an empty line below the first Text view.

Step 2

Type .pad, then pause to let Xcode show code completion suggestions. Use the arrow keys to highlight padding(_ edges:_ length:) in the menu, then press Return to insert the .padding modifier into your code.

You can show or hide code completion by pressing Escape.

Step 3

The .padding modifier adds extra space around the edges of a view to separate it from its surrounding views.

You apply modifiers to views using dot notation. That’s why there’s a period before the word padding.

Step 4

Add a second modifier to give the chat bubble a background color and shape. Below .padding, type .back, then let Xcode show you code completion suggestions. Choose background(_ style:in:) and press Return to add it to your code.

There are often multiple versions of the same view or modifier. This version of the .background modifier lets you set the style (style: ShapeStyle) of the background and give it a shape (in: Shape).

Step 5

This modifier requires arguments between the parentheses to specify the style and shape. Xcode automatically highlights the placeholder for the first argument. Type Color.yellow for the first argument, then press Tab to move to the next argument.

You can see other color options by typing Color. and viewing the code completion list.

Step 6

Begin typing RoundedRectangle for the second argument to .background. From the code completion list, choose the version of RoundedRectangle with an argument labeled cornerRadius, and set the value of the cornerRadius to 8.

Step 7

Before adding modifiers to the next chat bubble, do a quick experiment to see how the order of modifiers affects your views. Reverse the order of the .background and .padding modifiers so that the padding comes after the background.

Notice how the chat bubble’s appearance changes. Why do you think the view changes when you reorder the modifiers?

Step 8

At the bottom leading corner of the preview, click the Selectable Mode button.

In a live preview — the default mode — you can interact with your interface to test it out. In selectable mode, you can click elements in the preview to see more information about them and to highlight the corresponding code in the source editor.

Step 9

Click the top message bubble to select it. Xcode shows the selection by drawing a thin blue border around it.

The selection rectangle encompasses the colored bubble and the empty padding around it.

Step 10

Restore the original modifier order by putting the padding before the background.

Now the colored bubble fills the selection rectangle.

Step 11

Take a look at the sequence of modifiers in your code.

The .padding modifier creates a new, padded view with empty space around it, which is affected by any modifiers coming after it. If you want the padded area to have a background color, you must modify that padded view.

Step 12

Change the preview back to live mode by clicking the Live Mode button.

Step 13

Add padding and background to the second chat bubble, this time selecting a different color — for example, Color.teal.

ContentView.swift
//
//  ContentView.swift
//  ChatPrototype
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            Text("Knock, knock!")
                .padding()
                .background(Color.yellow, in: RoundedRectangle(cornerRadius: 8))
            Text("Who's there?")
                .padding()
                .background(Color.teal, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}


#Preview {
    ContentView()
}