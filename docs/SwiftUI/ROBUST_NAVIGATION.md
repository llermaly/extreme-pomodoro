List
A container that presents rows of data arranged in a single column, optionally providing the ability to select one or more members.
iOS 13.0+
iPadOS 13.0+
Mac Catalyst 13.0+
macOS 10.15+
tvOS 13.0+
visionOS 1.0+
watchOS 6.0+
@MainActor @preconcurrency
struct List<SelectionValue, Content> where SelectionValue : Hashable, Content : View
Mentioned in
Picking container views for your content
Displaying data in lists
Grouping data with lazy stack views
Making a view into a drag source
Migrating to new navigation types
Overview
In its simplest form, a List creates its contents statically, as shown in the following example:

var body: some View {
    List {
        Text("A List Item")
        Text("A Second List Item")
        Text("A Third List Item")
    }
}
A vertical list with three text views.

More commonly, you create lists dynamically from an underlying collection of data. The following example shows how to create a simple list from an array of an Ocean type which conforms to Identifiable:

struct Ocean: Identifiable {
    let name: String
    let id = UUID()
}


private var oceans = [
    Ocean(name: "Pacific"),
    Ocean(name: "Atlantic"),
    Ocean(name: "Indian"),
    Ocean(name: "Southern"),
    Ocean(name: "Arctic")
]


var body: some View {
    List(oceans) {
        Text($0.name)
    }
}
A vertical list with five text views, each with the name of an

Supporting selection in lists
To make members of a list selectable, provide a binding to a selection variable. Binding to a single instance of the list data’s Identifiable.ID type creates a single-selection list. Binding to a Set creates a list that supports multiple selections. The following example shows how to add multiselect to the previous example:

struct Ocean: Identifiable, Hashable {
    let name: String
    let id = UUID()
}


private var oceans = [
    Ocean(name: "Pacific"),
    Ocean(name: "Atlantic"),
    Ocean(name: "Indian"),
    Ocean(name: "Southern"),
    Ocean(name: "Arctic")
]


@State private var multiSelection = Set<UUID>()


var body: some View {
    NavigationView {
        List(oceans, selection: $multiSelection) {
            Text($0.name)
        }
        .navigationTitle("Oceans")
        .toolbar { EditButton() }
    }
    Text("\(multiSelection.count) selections")
}
When people make a single selection by tapping or clicking, the selected cell changes its appearance to indicate the selection. To enable multiple selections with tap gestures, put the list into edit mode by either modifying the editMode value, or adding an EditButton to your app’s interface. When you put the list into edit mode, the list shows a circle next to each list item. The circle contains a checkmark when the user selects the associated item. The example above uses an Edit button, which changes its title to Done while in edit mode:

A navigation view with the title Oceans and a vertical list that contains

People can make multiple selections without needing to enter edit mode on devices that have a keyboard and mouse or trackpad, like Mac and iPad.

Refreshing the list content
To make the content of the list refreshable using the standard refresh control, use the refreshable(action:) modifier.

The following example shows how to add a standard refresh control to a list. When the user drags the top of the list downward, SwiftUI reveals the refresh control and executes the specified action. Use an await expression inside the action closure to refresh your data. The refresh indicator remains visible for the duration of the awaited operation.

struct Ocean: Identifiable, Hashable {
     let name: String
     let id = UUID()
     let stats: [String: String]
 }


 class OceanStore: ObservableObject {
     @Published var oceans = [Ocean]()
     func loadStats() async {}
 }


 @EnvironmentObject var store: OceanStore


 var body: some View {
     NavigationView {
         List(store.oceans) { ocean in
             HStack {
                 Text(ocean.name)
                 StatsSummary(stats: ocean.stats) // A custom view for showing statistics.
             }
         }
         .refreshable {
             await store.loadStats()
         }
         .navigationTitle("Oceans")
     }
 }
Supporting multidimensional lists
To create two-dimensional lists, group items inside Section instances. The following example creates sections named after the world’s oceans, each of which has Text views named for major seas attached to those oceans. The example also allows for selection of a single list item, identified by the id of the example’s Sea type.

struct ContentView: View {
    struct Sea: Hashable, Identifiable {
        let name: String
        let id = UUID()
    }


    struct OceanRegion: Identifiable {
        let name: String
        let seas: [Sea]
        let id = UUID()
    }


    private let oceanRegions: [OceanRegion] = [
        OceanRegion(name: "Pacific",
                    seas: [Sea(name: "Australasian Mediterranean"),
                           Sea(name: "Philippine"),
                           Sea(name: "Coral"),
                           Sea(name: "South China")]),
        OceanRegion(name: "Atlantic",
                    seas: [Sea(name: "American Mediterranean"),
                           Sea(name: "Sargasso"),
                           Sea(name: "Caribbean")]),
        OceanRegion(name: "Indian",
                    seas: [Sea(name: "Bay of Bengal")]),
        OceanRegion(name: "Southern",
                    seas: [Sea(name: "Weddell")]),
        OceanRegion(name: "Arctic",
                    seas: [Sea(name: "Greenland")])
    ]


    @State private var singleSelection: UUID?


    var body: some View {
        NavigationView {
            List(selection: $singleSelection) {
                ForEach(oceanRegions) { region in
                    Section(header: Text("Major \(region.name) Ocean Seas")) {
                        ForEach(region.seas) { sea in
                            Text(sea.name)
                        }
                    }
                }
            }
            .navigationTitle("Oceans and Seas")
        }
    }
}
Because this example uses single selection, people can make selections outside of edit mode on all platforms.

A vertical list split into sections titled Major Pacific Ocean Seas,

Note

In iOS 15, iPadOS 15, and tvOS 15 and earlier, lists support selection only in edit mode, even for single selections.

Creating hierarchical lists
You can also create a hierarchical list of arbitrary depth by providing tree-structured data and a children parameter that provides a key path to get the child nodes at any level. The following example uses a deeply-nested collection of a custom FileItem type to simulate the contents of a file system. The list created from this data uses collapsing cells to allow the user to navigate the tree structure.

struct ContentView: View {
    struct FileItem: Hashable, Identifiable, CustomStringConvertible {
        var id: Self { self }
        var name: String
        var children: [FileItem]? = nil
        var description: String {
            switch children {
            case nil:
                return "📄 \(name)"
            case .some(let children):
                return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
            }
        }
    }
    let fileHierarchyData: [FileItem] = [
      FileItem(name: "users", children:
        [FileItem(name: "user1234", children:
          [FileItem(name: "Photos", children:
            [FileItem(name: "photo001.jpg"),
             FileItem(name: "photo002.jpg")]),
           FileItem(name: "Movies", children:
             [FileItem(name: "movie001.mp4")]),
              FileItem(name: "Documents", children: [])
          ]),
         FileItem(name: "newuser", children:
           [FileItem(name: "Documents", children: [])
           ])
        ]),
        FileItem(name: "private", children: nil)
    ]
    var body: some View {
        List(fileHierarchyData, children: \.children) { item in
            Text(item.description)
        }
    }
}
A list providing an expanded view of a tree structure. Some rows have a

Styling lists
SwiftUI chooses a display style for a list based on the platform and the view type in which it appears. Use the listStyle(_:) modifier to apply a different ListStyle to all lists within a view. For example, adding .listStyle(.plain) to the example shown in the “Creating Multidimensional Lists” topic applies the plain style, the following screenshot shows:

A vertical list split into sections titled Major Pacific Ocean Seas,

Topics
Creating a list from a set of views
init(content: () -> Content)
Creates a list with the given content.
init(selection:content:)
Creates a list with the given content that supports selecting a single row that cannot be deselected.
Creating a list from enumerated data
init(_:rowContent:)
Creates a list that computes its rows on demand from an underlying collection of identifiable data.
init(_:selection:rowContent:)
Creates a list that computes its rows on demand from an underlying collection of identifiable data, optionally allowing users to select a single row.
init(_:id:rowContent:)
Creates a list that identifies its rows based on a key path to the identifier of the underlying data.
init(_:id:selection:rowContent:)
Creates a list that identifies its rows based on a key path to the identifier of the underlying data, optionally allowing users to select a single row.
Creating a list from hierarchical data
init(_:children:rowContent:)
Creates a hierarchical list that computes its rows on demand from a binding to an underlying collection of identifiable data.
init(_:children:selection:rowContent:)
Creates a hierarchical list that computes its rows on demand from a binding to an underlying collection of identifiable data and allowing users to have exactly one row always selected.
init(_:id:children:rowContent:)
Creates a hierarchical list that identifies its rows based on a key path to the identifier of the underlying data.
init(_:id:children:selection:rowContent:)
Creates a hierarchical list that identifies its rows based on a key path to the identifier of the underlying data and allowing users to have exactly one row always selected.
Creating a list from editable data
init<Data, RowContent>(Binding<Data>, editActions: EditActions<Data>, rowContent: (Binding<Data.Element>) -> RowContent)
Creates a list that computes its rows on demand from an underlying collection of identifiable data and enables editing the collection.
init(_:editActions:selection:rowContent:)
Creates a list that computes its rows on demand from an underlying collection of identifiable data, enables editing the collection, and requires a selection of a single row.
init<Data, ID, RowContent>(Binding<Data>, id: KeyPath<Data.Element, ID>, editActions: EditActions<Data>, rowContent: (Binding<Data.Element>) -> RowContent)
Creates a list that computes its rows on demand from an underlying collection of identifiable data and enables editing the collection.
init(_:id:editActions:selection:rowContent:)
Creates a list that computes its rows on demand from an underlying collection of identifiable data, enables editing the collection, and requires a selection of a single row.
Supporting types
var body: some View
The content of the list.
Relationships
Conforms To
View
See Also
Creating a list
Displaying data in lists
Visualize collections of data with platform-appropriate appearance.
func listStyle<S>(S) -> some View
Sets the style for lists within this view.


Overview
If your app has a minimum deployment target of iOS 16, iPadOS 16, macOS 13, tvOS 16, watchOS 9, or visionOS 1, or later, transition away from using NavigationView. In its place, use NavigationStack and NavigationSplitView instances. How you use these depends on whether you perform navigation in one column or across multiple columns. With these newer containers, you get better control over view presentation, container configuration, and programmatic navigation.

Update single column navigation
If your app uses a NavigationView that you style using the stack navigation view style, where people navigate by pushing a new view onto a stack, switch to NavigationStack.

In particular, stop doing this:

NavigationView { // This is deprecated.
    /* content */
}
.navigationViewStyle(.stack)
Instead, create a navigation stack:

NavigationStack {
    /* content */
}
Update multicolumn navigation
If your app uses a two- or three-column NavigationView, or for apps that have multiple columns in some cases and a single column in others — which is typical for apps that run on iPhone and iPad — switch to NavigationSplitView.

Instead of using a two-column navigation view:

NavigationView { // This is deprecated.
    /* column 1 */
    /* column 2 */
}
Create a navigation split view that has explicit sidebar and detail content using the init(sidebar:detail:) initializer:

NavigationSplitView {
    /* column 1 */
} detail: {
    /* column 2 */
}
Similarly, instead of using a three-column navigation view:

NavigationView { // This is deprecated.
    /* column 1 */
    /* column 2 */
    /* column 3 */
}
Create a navigation split view that has explicit sidebar, content, and detail components using the init(sidebar:content:detail:) initializer:

NavigationSplitView {
    /* column 1 */
} content: {
    /* column 2 */
} detail: {
    /* column 3 */
}
If you need navigation within a column, embed a navigation stack in that column. This arrangement provides finer control over what each column displays. NavigationSplitView also enables you to customize column visibility and width.

Update programmatic navigation
If you perform programmatic navigation using one of the NavigationLink initializers that has an isActive input parameter, move the automation to the enclosing stack. Do this by changing your navigation links to use the init(value:label:) initializer, then use one of the navigation stack initializers that takes a path input, like init(path:root:).

For example, if you have a navigation view with links that activate in response to individual state variables:

@State private var isShowingPurple = false
@State private var isShowingPink = false
@State private var isShowingOrange = false


var body: some View {
    NavigationView { // This is deprecated.
        List {
            NavigationLink("Purple", isActive: $isShowingPurple) {
                ColorDetail(color: .purple)
            }
            NavigationLink("Pink", isActive: $isShowingPink) {
                ColorDetail(color: .pink)
            }
            NavigationLink("Orange", isActive: $isShowingOrange) {
                ColorDetail(color: .orange)
            }
        }
    }
    .navigationViewStyle(.stack) 
}
When some other part of your code sets one of the state variables to true, the navigation link that has the matching tag activates in response.

Rewrite this as a navigation stack that takes a path input:

@State private var path: [Color] = [] // Nothing on the stack by default.


var body: some View {
    NavigationStack(path: $path) {
        List {
            NavigationLink("Purple", value: .purple)
            NavigationLink("Pink", value: .pink)
            NavigationLink("Orange", value: .orange)
        }
        .navigationDestination(for: Color.self) { color in
            ColorDetail(color: color)
        }
    }
}
This version uses the navigationDestination(for:destination:) view modifier to detach the presented data from the corresponding view. That makes it possible for the path array to represent every view on the stack. Changes that you make to the array affect what the container displays right now, as well as what people encounter as they navigate through the stack. You can support even more sophisticated programmatic navigation if you use a NavigationPath to store the path information, rather than a plain collection of data. For more information, see NavigationStack.

Update selection-based navigation
If you perform programmatic navigation on List elements that use one of the NavigationLink initializers with a selection input parameter, you can move the selection to the list. For example, suppose you have a navigation view with links that activate in response to a selection state variable:

let colors: [Color] = [.purple, .pink, .orange]
@State private var selection: Color? = nil // Nothing selected by default.


var body: some View {
    NavigationView { // This is deprecated.
        List {
            ForEach(colors, id: \.self) { color in
                NavigationLink(color.description, tag: color, selection: $selection) {
                    ColorDetail(color: color)
                }
            }
        }
        Text("Pick a color")
    }
}
Using the same properties, you can rewrite the body as:

var body: some View {
    NavigationSplitView {
        List(colors, id: \.self, selection: $selection) { color in
            NavigationLink(color.description, value: color)
        }
    } detail: {
        if let color = selection {
            ColorDetail(color: color)
        } else {
            Text("Pick a color")
        }
    }
}
The list coordinates with the navigation logic so that changing the selection state variable in another part of your code activates the navigation link with the corresponding color. Similarly, if someone chooses the navigation link associated with a particular color, the list updates the selection value that other parts of your code can read.

Provide backward compatibility with an availability check
If your app needs to run on platform versions earlier than iOS 16, iPadOS 16, macOS 13, tvOS 16, watchOS 9, or visionOS 1, you can start migration while continuing to support older clients by using an availability condition. For example, you can create a custom wrapper view that conditionally uses either NavigationSplitView or NavigationView:

struct NavigationSplitViewWrapper<Sidebar, Content, Detail>: View
    where Sidebar: View, Content: View, Detail: View
{
    private var sidebar: Sidebar
    private var content: Content
    private var detail: Detail
    
    init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail:  () -> Detail
    ) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }
    
    var body: some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *) {
            // Use the latest API.
            NavigationSplitView {
                sidebar
            } content: {
                content
            } detail: {
                detail
            }
        } else {
            // Support previous platform versions.
            NavigationView {
                sidebar
                content
                detail
            }
            .navigationViewStyle(.columns)
        }
    }
}
Customize the wrapper to meet your app’s needs. For example, you can add a navigation split view style modifier like navigationSplitViewStyle(_:) to the NavigationSplitView in the appropriate branch of the availability check.

See Also
Presenting views in columns
Bringing robust navigation structure to your SwiftUI app
Use navigation links, stacks, destinations, and paths to provide a streamlined experience for all platforms, as well as behaviors such as deep linking and state restoration.
struct NavigationSplitView
A view that presents views in two or three columns, where selections in leading columns control presentations in subsequent columns.
func navigationSplitViewStyle<S>(S) -> some View
Sets the style for navigation split views within this view.
func navigationSplitViewColumnWidth(CGFloat) -> some View
Sets a fixed, preferred width for the column containing this view.
func navigationSplitViewColumnWidth(min: CGFloat?, ideal: CGFloat, max: CGFloat?) -> some View
Sets a flexible, preferred width for the column containing this view.
struct NavigationSplitViewVisibility
The visibility of the leading columns in a navigation split view.
struct NavigationLink
A view that controls a navigation presentation.



Buttons and state
Update the UI with state
Explore how @State properties and buttons work to update the UI of your app by creating an app to roll virtual dice. Add the functionality to increase or decrease the number of dice on the screen to play different kinds of games.

Section 1
Create a custom view
In Customize views with properties, you learned to factor out repeated elements of your interface into a custom view. To make an app with multiple dice, create a custom view to represent a single dice, then use it to make more dice in your app.

Illustration of the top half of the Dice Roller app, showing an image of a single dice.
Step 1

Create an iOS App project in Xcode named DiceRoller.

Step 2

Create a SwiftUI view file named DiceView.

Step 3

Replace the body code with an image of a dice.

Experiment

SF Symbols has images for all six sides of a dice. Change the number at the end of the image name to see each one.

Step 4

Add a property to the view to represent the number of pips on the dice.

You use the assignment operator = to give the property a default value of 1.

Step 5

This property is marked with the keyword var, which means you can assign new values to it. This view is dynamic; you’ll change the value of the property when people roll the dice.

When you assign a default value to a structure’s property, it’s not required in the initializer. That’s why you didn’t have to change the DiceView instance in the preview to include numberOfPips.

Step 6

Use string interpolation to display the dice image using the value of your new property.

Experiment

Change the default value of numberOfPips to see the corresponding dice images.

Step 7

Use modifiers to increase the size of the image. The .resizable modifier tells the image it can stretch to fill any available space. You don’t want the dice to fill all the available space, so you limit the image by setting its frame size.

You typically match the size of SF Symbols to their surrounding content using the .font modifier. In this case, you’re using the image as purely graphical content, so it’s OK to use .resizable and .frame.

DiceView.swift
//
//  DiceView.swift
//  DiceRoller
//
//
//


import SwiftUI


struct DiceView: View {
    var numberOfPips: Int = 1
    
    var body: some View {
        Image(systemName: "die.face.\(numberOfPips)")
            .resizable()
            .frame(width: 100, height: 100)
    }
}


#Preview {
    DiceView()
}

Preview
Screenshot showing the preview with a single large dice image in the center.
Section 2
Add a button to roll the dice
Use a Button to change the image of the dice. A button uses a closure to run code when a person taps it.

Step 1

Embed the image in a VStack so that you can add the button below it.

Step 2

Inside the VStack, below the Image and its modifiers, start typing Button. Code completion offers you several suggestions; choose the one with a titleKey and an action.

If you see title instead of titleKey, choose that initializer.

Step 3

Replace the first placeholder with the string "Roll".

Step 4

The second parameter, action: () -> Void, requires a closure that executes code when people tap the button. Press Tab to select the placeholder, then press Return.

Xcode removes the action parameter completely and replaces it with a closure contained in a pair of braces. There’s a code placeholder inside the braces where you’ll write your code for the button.

Step 5

Replace the last placeholder with code to choose a random number of pips for the dice. There’s an error in your code that you’ll fix in the next section by changing numberOfPips into a @State property.

Int.random selects a random integer from the range inside its parentheses; the code 1...6 creates a range of integers from 1 to 6.

Note

This is another example of using an assignment operator. This time, you’re updating the value of numberOfPips every time the code runs.

DiceView.swift
//
//  DiceView.swift
//  DiceRoller
//
//
//


import SwiftUI


struct DiceView: View {
    var numberOfPips: Int = 1
    
    var body: some View {
        VStack {
            Image(systemName: "die.face.\(numberOfPips)")
                .resizable()
                .frame(width: 100, height: 100)
            
            Button("Roll") {
                numberOfPips = Int.random(in: 1...6)
            }
        }
    }
}


#Preview {
    DiceView()
}

No Preview
Section 3
Use state to update a view
All apps have data, or state, that changes over time. When an app changes state, it may need to update its interface. Dice Roller needs to update the image when someone taps the Roll button and the numberOfPips property changes.

Illustration of the top half of the Dice Roller app, showing an image of a single dice and a button beneath it labeled Roll.
Step 1

Make numberOfPips a @State property. Then tap the Roll button a few times to check that the image changes.

SwiftUI doesn’t monitor every property in an app for changes by default. Marking a property with @State tells SwiftUI to monitor the property and update the UI when it changes.

Note

View state is owned by the view. You always mark state properties private so other views can’t interfere with their value.

Step 2

Add a border to the button to set it apart from the image.

Step 3

To make the transition fade from the old dice image to the new one, use withAnimation to animate the change.

Adding withAnimation instructs SwiftUI to animate any state changes that occur within its code. It uses a trailing closure, similar to the way Button works.

DiceView.swift
//
//  DiceView.swift
//  DiceRoller
//
//
//


import SwiftUI


struct DiceView: View {
    @State private var numberOfPips: Int = 1
    
    var body: some View {
        VStack {
            Image(systemName: "die.face.\(numberOfPips)")
                .resizable()
                .frame(width: 100, height: 100)
            
            Button("Roll") {
                withAnimation {
                    numberOfPips = Int.random(in: 1...6)
                }
            }
            .buttonStyle(.bordered)
        }
    }
}


#Preview {
    DiceView()
}

Preview
Play
Section 4
Create a dynamic display of dice
Add functionality to choose the number of dice by creating another property. Marking the property with @State ensures that the interface updates when the number of dice changes.

Illustration of the top half of the Dice Roller app, showing the app title, then three dice with buttons beneath them labeled Roll, then buttons labeled Remove Dice and Add Dice. The Add Dice button is disabled.
Step 1

In ContentView, replace the contents of the VStack with a title.

You can use modifiers on the Font type the same way you use them with views.

Experiment

Chain other Font modifiers on .largeTitle to see the effects.

If you want, you can put the modifiers on separate lines:

.font(.largeTitle
    .lowercaseSmallCaps()
    .bold()
)
Step 2

Add an HStack with three DiceView instances. Try rolling each dice.

Step 3

To be able to display any number of dice, use a ForEach view. Repeat DiceView three times by using a range from 1 to 3. Type the code manually; ForEach has code completion options for many different uses.

The ForEach view is dynamic; it computes its subviews based on its input, which may change with the state of the app. You create a range using 1...3, just as you did in Int.random(in: 1...6). The ForEach view creates one DiceView for each value in the range.

Step 4

The 1...3 range is static. To make it adapt to any number of dice, you’ll again use view state. Add a state property for the number of dice.

Step 5

Use the new property to make the range dynamic.

Experiment

Try changing the default value of numberOfDice to see how the interface changes.

Step 6

Below the ForEach view and the HStack, add two buttons to increase and decrease the number of dice.

Look at the code inside each button’s closure. In Swift, you can use += and –= to add or subtract from a property’s current value. In this case you’re adding or subtracting 1.

Experiment

Try out the buttons to make sure they work.

Step 7

Reduce the number of dice to one, then tap the Remove Dice button. The preview crashes, because the range 1...0 isn’t valid.

Step 8

To prevent people from tapping the Remove Dice button when there’s only one DiceView, you can disable the button to prevent the crash and give people a visual cue that the button is unresponsive. Use the .disabled modifier to disable the Remove Dice button when numberOfDice has a value of 1.

You use the == operator to check whether two numbers are equal. The result of this comparison is a Bool, which has one of two values: true or false. When numberOfDice == 1 is true, the modifier disables the button.

Step 9

The images of the dice are fixed at 100x100 points, so only three dice images fit on the screen. Use the .disabled modifier with the Add Dice button to prevent people from having more than three dice.

Step 10

Animate the changes to the number of dice using withAnimation.

ContentView.swift
//
//  ContentView.swift
//  DiceRoller
//
//
//


import SwiftUI


struct ContentView: View {
    @State private var numberOfDice: Int = 1
    
    var body: some View {
        VStack {
            Text("Dice Roller")
                .font(.largeTitle.lowercaseSmallCaps())
            
            HStack {
                ForEach(1...numberOfDice, id: \.description) { _ in
                    DiceView()
                }
            }
            
            HStack {
                Button("Remove Dice") {
                    numberOfDice -= 1
                }
                .disabled(numberOfDice == 1)
                
                Button("Add Dice") {
                    numberOfDice += 1
                }
                .disabled(numberOfDice == 3)
            }
            .padding()
        }
        .padding()
    }
}


#Preview {
    ContentView()
}


