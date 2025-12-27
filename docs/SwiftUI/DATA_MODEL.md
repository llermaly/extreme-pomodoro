
Models and persistence
Save data
Explore data modeling for the first time by building an app that displays your friends and their birthdays. Start by creating a model to represent the data, then integrate with the SwiftData framework so you can save data between launches of the app.

Section 1
Create a project
Start a new project in Xcode.

Illustration of a phone screen with a globe above the words hello world.
Step 1

Create an iOS App project in Xcode named Birthdays.

Step 2

In the Project Options dialog, choose None for storage. You’ll be starting from scratch to build your data storage solution.

Screenshot showing the options for a new Xcode project. Storage, None is highlighted.
Section 2
Create a type to represent a friend
Make a new Swift file and create a Friend type to hold a name and a birthday.

Illustration of the top half of a birthdays view, with the title birthdays at the top and a list of two names next to birthdates below.
Step 1

Create a Swift file named Friend. In it, declare a new struct called Friend.

Step 2

Create two properties: one to represent the friend’s name and one to represent their birth date.

The Swift Date type represents a specific point in time, down to fractions of a second.

Step 3

In ContentView, declare an array of friends.

Step 4

Use the Friend initializer to create sample data for the preview. The sample names in this project are only suggestions. Make it your own by using the names of people you know.

Date.now captures the exact moment that the code runs.

Note

You use commas to separate items in an array. Some programmers also choose to include a comma after the last item, as you’ve done here. This is known as a trailing comma or dangling comma. When you put items in an array on their own lines and use a trailing comma after the last one, you don’t need to modify that line of code if you later add or reorder array items. You can see this in the next step, where you add new elements without changing the existing line.

Step 5

Create another sample friend with a birthday in the past.

A Date is stored as seconds past a fixed reference. The start of the year 1970 is one of those reference dates, known as the Unix epoch.

Step 6

Replace the body code with a List of friends. Use the name property as the id of Friend.

Because IDs must be unique, using name for the ID means you can’t have two friends with the same name. You’ll address this issue later.

Step 7

Start populating the list by displaying each friend’s name.

Step 8

Display the friends’ birthdays using the day, month, and year.

The format declaration is semantic: You specify the parts of the date you want to display and let the system render the text according to the device’s current calendar.

Note

Depending on where you are in the world, you’ll see either January 1, 1970, or December 31, 1969, for Jenny’s birth date. These are both representations of the exact moment of her birth; which one you see depends on the time zone that you’re in.

Step 9

Embed the List in a NavigationStack view and use the .navigationTitle modifier to display the title “Birthdays” at the top of the screen.

NavigationStack is often used to stack views on top of each other, like a stack of cards. Only the top view is visible at any time, and you manipulate the stack by adding views to or taking views off the top of the stack. The primary purpose of NavigationStack is navigation, but it also offers functionality like navigation bars, buttons, toolbars, and titles.

Experiment

Scroll the list and title up to see the title move into the navigation bar.

ContentView.swift
import SwiftUI


struct ContentView: View {
    @State private var friends: [Friend] = [
        Friend(name: "Elton Lin", birthday: .now),
        Friend(name: "Jenny Court", birthday: Date(timeIntervalSince1970: 0))
    ]


    var body: some View {
        NavigationStack {
            List(friends, id: \.name) { friend in
                HStack {
                    Text(friend.name)
                    Spacer()
                    Text(friend.birthday, format: .dateTime.month(.wide).day().year())
                }
            }
            .navigationTitle("Birthdays")
        }
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot with two friends below a large title reading Birthdays.
Section 3
Enter data
Create a user interface for entering friend data.

You’ll build an area at the bottom of the screen to add your friends’ birthdays, then create a Friend and add it to the list.

Illustration of the bottom half of a birthdays view with new birthday controls pinned to the bottom. The text new birthday is followed by a side-by-side textfield with placeholder Name and date picker showing July 31, 2024. Below, a centered blue save button completes the new birthday controls.
Step 1

Declare two new @State properties to contain the values for a new Friend.

Step 2

Use .safeAreaInset(edge: .bottom) to pin your new friend-entry UI to the bottom of the screen, below the list of friends.

.safeAreaInset can anchor content to any side of the screen.

Step 3

Start the entry UI with a VStack that spaces out each element and contains a static Text.

Step 4

Add a DatePicker — a component for choosing Date values — and a TextField for the friend’s name.

The closure following DatePicker contains its label. The “New Birthday” title describes what goes into the date picker just fine, so use the label to display the TextField.

Step 5

Configure the DatePicker so you can’t select a date in the future.

The last argument, displayedComponents: .date, sets the picker to display only the controls for the date. You can also specify .hourAndMinute or .hourMinuteAndSecond to specify controls for the time. To let someone pick a date with full precision, you can combine them, like [.date, .hourMinuteAndSecond].

Step 6

Add a Save button that creates a Friend model. Use the .bold modifier to make it stand out.

newFriend is an instance of Friend that contains the entered name and birthday. Recall that Friend is not a view and has no body; it models those two pieces of data.

Step 7

Add the new friend to the array that powers the List.

.append places the new friend at the end of the array. The change to the array triggers a SwiftUI update, and the name is rendered at the bottom of the list.

Step 8

Reset the new friend state values to their default values. That makes it easier to continue adding birthdays.

Step 9

Add padding and style the safe area to complete the data entry UI.

.bar styles the background in the same style as a system toolbar. You’ll learn more about toolbars in the next tutorial.

Step 10

Launch the simulator and add a few friends. Relaunch the simulator to see that your new friends have disappeared.

In the next section, you’ll learn how to save the data you enter using SwiftData.

Play
Section 4
Convert your structure to a SwiftData model
An app to help you remember birthdays isn’t much use if it doesn’t store the data you enter. You’ll use the SwiftData framework to create and store instances of Friend so they are still there when the app is relaunched.

Step 1

Open the Friend file and import SwiftData.

SwiftData provides tools to model the data in your app and to use persistence to save your data so that it doesn’t disappear when someone leaves the app.

Step 2

Add the @Model macro annotation above the Friend structure.

SwiftData gives you access to the @Model macro. Macros modify existing code with new functionality. In this case, @Model converts a Swift class into a stored model managed by SwiftData.

Note

Macros add hidden code, which may have requirements that cause errors until they are fulfilled. You’ll find and resolve those errors in the next steps.

Step 3

Choose Product > Build to build your project. There are several errors, some informing you that @Model requires Friend to be a class instead of a struct. Make Friend a class.

A class and a struct both hold data, but instances of a class have a built-in identity that instances of a struct don’t have. SwiftData uses this identity to share its model data across the entire app, to any view that needs it. When any view modifies a model, SwiftData sees those changes immediately.

Note

When building a project results in errors, the navigator area displays those errors in the issue navigator. Once you resolve the errors and are ready to open another file, switch back to the project navigator.

Step 4

Add an initializer to Friend. Then, build your project again to see that the errors are resolved.

An initializer creates an instance of a type by assigning values to every property. For structures, Swift generates an initializer with arguments matching each of its properties. But classes don’t get autogenerated initializers, so you need to create one.

Friend.swift
import Foundation
import SwiftData


@Model
class Friend {
    var name: String
    var birthday: Date


    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
    }
}

No Preview
Section 5
Connect SwiftData and SwiftUI
Learn to power SwiftUI with a SwiftData model by upgrading the @State array to SwiftData queries and operations.

Birthdays won’t build until you complete all the steps in this section, so don’t get discouraged when you see errors as you work through the steps. You’ll need to set up a container, change your @State array to use SwiftData, and then save new friends correctly before you see the app working again.

Step 1

In BirthdaysApp, import SwiftData, then connect SwiftData and SwiftUI using the modifier .modelContainer and the Friend model.

The container is like a translator that sits between where the Friend data is stored and the ContentView onscreen. Friend.self references the type Friend rather than a specific friend. The container uses the type blueprint to understand how the model should be saved.

Step 2

In ContentView, import SwiftData. Then, add a similar model container in the preview, setting inMemory to true.

Previews should start in the same initial state every time they refresh. By specifying inMemory as true, you tell the container to use an in-memory container. In-memory refers to the storage mechanism: Data is stored only as long as the app is in memory.

Step 3

Change the annotation on your friends array from @State to @Query to fetch Friend instances stored in SwiftData. Remove the sample data in the array.

As the name suggests, @Query asks SwiftData for an array of data — in this case, [Friend]. When you update the instances of Friend stored in SwiftData, the query updates your views, just like a @State property does.

Note

Sample data in SwiftData can’t be created directly in a Query. You’ll add the sample data back once the errors are resolved at the end of this section.

Step 4

SwiftData requires a ModelContext to save new items. Access the \.modelContext environment value.

A ModelContext provides a connection between the view and the model container so that you can fetch, insert, and delete items in the container. The .modelContainer modifier you added to ContentView inserts a modelContext into the SwiftUI environment, and that modelContext is accessible to all views under the container.

Step 5

In your Save button code, replace the local append method with one that inserts the new Friend model into the ModelContext.

Inserting into the ModelContext saves the new Friend into the container. Because @Query is also connected to the container, it picks up and displays the new Friend without you explicitly adding newFriend to friends.

Step 6

Re-create your sample data inside a .task, then save the data into SwiftData.

SwiftUI begins executing the code in a .task before the view appears. Here, when you insert the model objects, @Query picks them up and updates the friends property.

Experiment

Run the app in the simulator by choosing Product > Run. Then run the app again. Why do you think there are so many friends in the simulator compared to the preview?

ContentView.swift
import SwiftUI
import SwiftData


struct ContentView: View {
    @Query private var friends: [Friend]
    @Environment(\.modelContext) private var context


    @State private var newName = ""
    @State private var newDate = Date.now


    var body: some View {
        NavigationStack {
            List(friends, id: \.name) { friend in
                HStack {
                    Text(friend.name)
                    Spacer()
                    Text(friend.birthday, format: .dateTime.month(.wide).day().year())
                }
            }
            .navigationTitle("Birthdays")
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: 20) {
                    Text("New Birthday")
                        .font(.headline)
                    DatePicker(selection: $newDate, in: Date.distantPast...Date.now, displayedComponents: .date) {
                        TextField("Name", text: $newName)
                            .textFieldStyle(.roundedBorder)
                    }
                    Button("Save") {
                        let newFriend = Friend(name: newName, birthday: newDate)
                        context.insert(newFriend)


                        newName = ""
                        newDate = .now
                    }
                    .bold()
                }
                .padding()
                .background(.bar)
            }
            .task {
                context.insert(Friend(name: "Elton Lin", birthday: .now))
                context.insert(Friend(name: "Jenny Court", birthday: Date(timeIntervalSince1970: 0)))
            }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Friend.self, inMemory: true)
}

Preview
Screenshot with 2 friends each with readable birthdates.
Section 6
Use model data to fill out the UI
Organize your friends by age and highlight those who have a birthday today.

Illustration of the top half of the completed birthdays view, with a list of two names. One name is bold and includes a birthday cake icon next to it.
Step 1

SwiftData provides each instance of a model type with its own identity separate from its data. In your List, remove the explicit id to use the identifier provided by @Model.

You were using the name property to identify each instance of Friend in the List, but now SwiftData can identify the instances for you. Having two friends with the same name is no longer a problem.

Step 2

You may have noticed the two sample friends don’t always appear in the same order. Sort the list of friends chronologically using their birthdays.

Recall that dates are absolute points in time. A birth date in an earlier year comes before one in a later year, regardless of the months and days.

Experiment

Try adding another person with a birthday between Elton’s and Jenny’s.

Step 3

In Friend, add a computed property to calculate whether the friend’s birthday is celebrated today.

A Calendar translates an absolute point in time (a Date) into familiar units like years, months, minutes, and seconds. People across the world use many different calendar systems; Calendar.current accesses the calendar preference from the device running the app.

Step 4

In ContentView, use isBirthdayToday to draw attention to the name of any friends whose birthday is today with bold text and a cake SF Symbol.

isBirthdayToday is available on any Friend instance. The property is declared once in Friend but used twice here in ContentView. Grouping functionality into a logically connected type is a great way to keep code organized and discoverable.

Experiment

Look through SF Symbols for party-related alternatives to the cake. Swap one in, and if you like it better, keep it.

Step 5

Remove the .task prepopulating your app with data.

Step 6

Launch the app in the simulator and experiment with your fully featured Birthdays app. Add your friend’s birthdays and see them sorted by birthday.

If you did the experiment at the end of section 5, you’ll still see sample data. To start over, either delete the app in the simulator or use Device -> Erase All Content and Settings…

Screenshot with 4 friends, half are duplicates of the other half.