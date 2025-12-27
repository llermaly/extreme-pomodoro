Layout
A consistent layout that adapts to various contexts makes your experience more approachable and helps people enjoy their favorite apps and games on all their devices.
A sketch of a small rectangle in the upper-left quadrant of a larger rectangle, suggesting the position of a user interface element within a window. The image is overlaid with rectangular and circular grid lines and is tinted yellow to subtly reflect the yellow in the original six-color Apple logo.

Your app’s layout helps ground people in your content from the moment they open it. People expect familiar relationships between controls and content to help them use and discover your app’s features, and designing the layout to take advantage of this makes your app feel at home on the platform.

Apple provides templates, guides, and other resources that can help you integrate Apple technologies and design your apps and games to run on all Apple platforms. See Apple Design Resources.

Best practices
Group related items to help people find the information they want. For example, you might use negative space, background shapes, colors, materials, or separator lines to show when elements are related and to separate information into distinct areas. When you do so, ensure that content and controls remain clearly distinct.

Make essential information easy to find by giving it sufficient space. People want to view the most important information right away, so don’t obscure it by crowding it with nonessential details. You can make secondary information available in other parts of the window, or include it in an additional view.

Extend content to fill the screen or window. Make sure backgrounds and full-screen artwork extend to the edges of the display. Also ensure that scrollable layouts continue all the way to the bottom and the sides of the device screen. Controls and navigation components like sidebars and tab bars appear on top of content rather than on the same plane, so it’s important for your layout to take this into account.

When your content doesn’t span the full window, use a background extension view to provide the appearance of content behind the control layer on either side of the screen, such as beneath the sidebar or inspector. For developer guidance, see backgroundExtensionEffect() and UIBackgroundExtensionView.

A screenshot of a full screen iPad app with a sidebar on the leading edge. A photo of Mount Fuji fills the top half of the content area. The photo subtly blurs as it reaches the top of the screen, where toolbar items float above it grouped on the trailing edge. Where the photo meets the sidebar, the image flips, blurs, and extends fully beneath the sidebar to the edge of the screen.

Visual hierarchy
Differentiate controls from content. Take advantage of the Liquid Glass material to provide a distinct appearance for controls that’s consistent across iOS, iPadOS, and macOS. Instead of a background, use a scroll edge effect to provide a transition between content and the control area. For guidance, see Scroll views.

Place items to convey their relative importance. People often start by viewing items in reading order — that is, from top to bottom and from the leading to trailing side — so it generally works well to place the most important items near the top and leading side of the window, display, or field of view. Be aware that reading order varies by language, and take right to left languages into account as you design.

Align components with one another to make them easier to scan and to communicate organization and hierarchy. Alignment makes an app look neat and organized and can help people track content while scrolling or moving their eyes, making it easier to find information. Along with indentation, alignment can also help people understand an information hierarchy.

Take advantage of progressive disclosure to help people discover content that’s currently hidden. For example, if you can’t display all the items in a large collection at once, you need to indicate that there are additional items that aren’t currently visible. Depending on the platform, you might use a disclosure control, or display parts of items to hint that people can reveal additional content by interacting with the view, such as by scrolling.

Make controls easier to use by providing enough space around them and grouping them in logical sections. If unrelated controls are too close together — or if other content crowds them — they can be difficult for people to tell apart or understand what they do, which can make your app or game hard to use. For guidance, see Toolbars.

Adaptability
Every app and game needs to adapt when the device or system context changes. In iOS, iPadOS, tvOS, and visionOS, the system defines a collection of traits that characterize variations in the device environment that can affect the way your app or game looks. Using SwiftUI or Auto Layout can help you ensure that your interface adapts dynamically to these traits and other context changes; if you don’t use these tools, you need to use alternative methods to do the work.

Here are some of the most common device and system variations you need to handle:

Different device screen sizes, resolutions, and color spaces

Different device orientations (portrait/landscape)

System features like Dynamic Island and camera controls

External display support, Display Zoom, and resizable windows on iPad

Dynamic Type text-size changes

Locale-based internationalization features like left-to-right/right-to-left layout direction, date/time/number formatting, font variation, and text length

Design a layout that adapts gracefully to context changes while remaining recognizably consistent. People expect your experience to work well and remain familiar when they rotate their device, resize a window, add another display, or switch to a different device. You can help ensure an adaptable interface by respecting system-defined safe areas, margins, and guides (where available) and specifying layout modifiers to fine-tune the placement of views in your interface.

Be prepared for text-size changes. People appreciate apps and games that respond when they choose a different text size. When you support Dynamic Type — a feature that lets people choose the size of visible text in iOS, iPadOS, tvOS, visionOS, and watchOS — your app or game can respond appropriately when people adjust text size. To support Dynamic Type in your Unity-based game, use Apple’s accessibility plug-in (for developer guidance, see Apple – Accessibility). For guidance on displaying text in your app, see Typography.

Preview your app on multiple devices, using different orientations, localizations, and text sizes. You can streamline the testing process by first testing versions of your experience that use the largest and the smallest layouts. Although it’s generally best to preview features like wide-gamut color on actual devices, you can use Xcode Simulator to check for clipping and other layout issues. For example, if your iOS app or game supports landscape mode, you can use Simulator to make sure your layouts look great whether the device rotates left or right.

When necessary, scale artwork in response to display changes. For example, viewing your app or game in a different context — such as on a screen with a different aspect ratio — might make your artwork appear cropped, letterboxed, or pillarboxed. If this happens, don’t change the aspect ratio of the artwork; instead, scale it so that important visual content remains visible. In visionOS, the system automatically scales a window when it moves along the z-axis.

Guides and safe areas
A layout guide defines a rectangular region that helps you position, align, and space your content on the screen. The system includes predefined layout guides that make it easy to apply standard margins around content and restrict the width of text for optimal readability. You can also define custom layout guides. For developer guidance, see UILayoutGuide and NSLayoutGuide.

A safe area defines the area within a view that isn’t covered by a toolbar, tab bar, or other views a window might provide. Safe areas are essential for avoiding a device’s interactive and display features, like Dynamic Island on iPhone or the camera housing on some Mac models. For developer guidance, see SafeAreaRegions and Positioning content relative to the safe area.

Respect key display and system features in each platform. When an app or game doesn’t accommodate such features, it doesn’t feel at home in the platform and may be harder for people to use. In addition to helping you avoid display and system features, safe areas can also help you account for interactive components like bars, dynamically repositioning content when sizes change.

For templates that include the guides and safe areas for each platform, see Apple Design Resources.

Platform considerations
iOS
Aim to support both portrait and landscape orientations. People appreciate apps and games that work well in different device orientations, but sometimes your experience needs to run in only portrait or only landscape. When this is the case, you can rely on people trying both orientations before settling on the one you support — there’s no need to tell people to rotate their device. If your app or game is landscape-only, make sure it runs equally well whether people rotate their device to the left or the right.

Prefer a full-bleed interface for your game. Give players a beautiful interface that fills the screen while accommodating the corner radius, sensor housing, and features like Dynamic Island. If necessary, consider giving players the option to view your game using a letterboxed or pillarboxed appearance.

Avoid full-width buttons. Buttons feel at home in iOS when they respect system-defined margins and are inset from the edges of the screen. If you need to include a full-width button, make sure it harmonizes with the curvature of the hardware and aligns with adjacent safe areas.

Hide the status bar only when it adds value or enhances your experience. The status bar displays information people find useful and it occupies an area of the screen most apps don’t fully use, so it’s generally a good idea to keep it visible. The exception is if you offer an in-depth experience like playing a game or viewing media, where it might make sense to hide the status bar.

iPadOS
People can freely resize windows down to a minimum width and height, similar to window behavior in macOS. It’s important to account for this resizing behavior and the full range of possible window sizes when designing your layout. For guidance, see Multitasking and Windows.

As someone resizes a window, defer switching to a compact view for as long as possible. Design for a full-screen view first, and only switch to a compact view when a version of the full layout no longer fits. This helps the UI feel more stable and familiar in as many situations as possible. For more complex layouts such as split views, prefer hiding tertiary columns such as inspectors as the view narrows.

Test your layout at common system-provided sizes, and provide smooth transitions. Window controls provide the option to arrange windows to fill halves, thirds, and quadrants of the screen, so it’s important to check your layout at each of these sizes on a variety of devices. Be sure to minimize unexpected UI changes as people adjust down to the minimum and up to the maximum window size.

Consider a convertible tab bar for adaptive navigation. For many apps, you don’t need to choose between a tab bar or sidebar for navigation; instead, you can adopt a style of tab bar that provides both. The app first launches with your choice of a sidebar or a tab bar, and then people can tap to switch between them. As the view resizes, the presentation style changes to fit the width of the view. For guidance, see Tab bars. For developer guidance, see sidebarAdaptable.

macOS
Avoid placing controls or critical information at the bottom of a window. People often move windows so that the bottom edge is below the bottom of the screen.

Avoid displaying content within the camera housing at the top edge of the window. For developer guidance, see NSPrefersDisplaySafeAreaCompatibilityMode.

tvOS
Be prepared for a wide range of TV sizes. On Apple TV, layouts don’t automatically adapt to the size of the screen like they do on iPhone or iPad. Instead, apps and games show the same interface on every display. Take extra care in designing your layout so that it looks great in a variety of screen sizes.

Adhere to the screen’s safe area. Inset primary content 60 points from the top and bottom of the screen, and 80 points from the sides. It can be difficult for people to see content that close to the edges, and unintended cropping can occur due to overscanning on older TVs. Allow only partially displayed offscreen content and elements that deliberately flow offscreen to appear outside this zone.

An illustration of a TV with a safe zone border on all sides. In width, the top and bottom borders measure 60 points, and the side borders both measure 80 points.

Include appropriate padding between focusable elements. When you use UIKit and the focus APIs, an element gets bigger when it comes into focus. Consider how elements look when they’re focused, and make sure you don’t let them overlap important information. For developer guidance, see About focus interactions for Apple TV.

An illustration that uses vertical shaded rectangles to show padding between focusable items.

Grids
The following grid layouts provide an optimal viewing experience. Be sure to use appropriate spacing between unfocused rows and columns to prevent overlap when an item comes into focus.

If you use the UIKit collection view flow element, the number of columns in a grid is automatically determined based on the width and spacing of your content. For developer guidance, see UICollectionViewFlowLayout.

Two-column
Three-column
Four-column
Five-column
Six-column
Seven-column
Eight-column
Nine-column
An illustration of Apple TV, displaying a two-column grid of media items. Additional media items are partially visible on the right side and bottom edge of the screen.

Two-column grid
Attribute

Value

Unfocused content width

860 pt

Horizontal spacing

40 pt

Minimum vertical spacing

100 pt

Include additional vertical spacing for titled rows. If a row has a title, provide enough spacing between the bottom of the previous unfocused row and the center of the title to avoid crowding. Also provide spacing between the bottom of the title and the top of the unfocused items in the row.

Use consistent spacing. When content isn’t consistently spaced, it no longer looks like a grid and it’s harder for people to scan.

Make partially hidden content look symmetrical. To help direct attention to the fully visible content, keep partially hidden offscreen content the same width on each side of the screen.


Presenting Content
Laying Out Views
Organize, size and align view layouts.

When creating an app, one of the first skills to learn is how to lay out your user interface, or UI. When laying out a UI, there are three major things you need to do:

Organize your views in different configurations using container views.

Fine tune the sizing, spacing, alignment, and positioning of your views.

Debug your views when something goes wrong.

In this sample, you’ll learn all of these skills and more. Ready to start your journey into view layout?

Project files
Xcode 14 or later
Section 1
Organize your views
Step 1

A view can act as a container that holds and organizes other views, known as subviews. The VStack that holds all of your code is an example of a container view that organizes the two shape subviews vertically.

Step 2

Shape views expand to fill the entire space that’s offered by the container view. Because there are two shape views that need to share the space in the VStack equally, their sizes adapt accordingly.

Step 3

You can also organize your views on top of each other using a ZStack. To stack a circle view on top of a rectangle, the views need to be put into a ZStack.

Step 4

If you want to organize a pair of circles horizontally, you can use an HStack.

Step 5

You may have noticed that you have stacks that contain other stacks. SwiftUI organizes and tracks the relationships of views using a view hierarchy.

Step 6

There are more containers than just HStack, VStack, and ZStack views. To explore different containers and how to use them to lay out your content, see Picking container views for your content

LayingOutContainersView.swift
import SwiftUI


struct LayingOutContainersView: View {
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.themeBlue)
                Circle()
                    .foregroundColor(.themePink)
            }
            ZStack {
                Rectangle()
                    .foregroundColor(.themeBlue)
                HStack {
                    Circle()
                        .foregroundColor(.themeRed)
                    Circle()
                        .foregroundColor(.themeOrange)
                }
            }
        }
    }
}

Preview
A screenshot of a pink circle on top of a blue rectangle and above a pair of horizontally stacked circles on top of a blue rectangle.
Section 2
Modify and determine view sizes
Step 1

A SwiftUI View determines its size based on the space offered by its container view. That’s why this rectangle is taking up the entire view – because that’s what the parent VStack is doing.

Tip

Different views have different space requirements; not all views take up the same amount of space.

Step 2

Notice that there are Text and Image views in your VStack. No matter how big the screen you’re using, the Text and Image views take up exactly the amount of space they need depending on the size of the content.

Note

Often times you need to add size constraints to images since they can be extremely large.

Step 3

Because all views are unique, different types of views have their own space requirements within a container. This is why the Rectangle view adjusts how much space it takes up, but the Text and Image only take up as much space as they need.

Step 4

Views are somewhat magical, in that certain view types control how they resize when placed in a container. They can expand to fill the available space, such as Rectangle or other Shape.

Step 5

Views can also resize to fit their content such as Text(“Supercalifragilisticexpialidocious”) or Image("myCoolImage").

Note

A view can also maintain a specific size that doesn’t change, like Stepper.

Step 6

To adjust the amount of space views need, you can specify which view needs to take up more space. The frame(width:height:alignment:) allows you to adjust the size of a view. The frame modifier is setting a specific height and width for the rose image view.

Step 7

Providing fixed values for the width and height limits how adaptive the view can be. 🙃

Tip

A better way to do this is to give a maximum, minimum, or ideal width and height for a view. This allows the view to resize as necessary based on how much space is available in the container.

Step 8

When you use the frame modifer on an Image it only affects the size of the displayed image if you first use the .resizable modifier to indicate that you want the image to be resized as its frame changes.

Warning

Adding resizable after frame causes a compiler error. Applying the frame modifier to the Image actually creates a new view that’s no longer an Image, so it doesn’t have access to the resizable modifier.

Step 9

Adding a frame to an image can sometimes cause it to look stretched even by adding an ideal width and height. For images, it’s often better to use scaledToFill() or doc://com.apple.documentation/documentation/swiftui/menu/scaledtofit() instead of a frame.

Tip

Using both can help get a precise size for an image that is not distorted or too large.

Step 10

If you want to make the text bigger or different than the default, you can add the font(_:) modifier to your Text view.

Note

If you add the frame to the Text view, the actual text inside the view doesn’t change — it makes the view holding the text larger. This allows for more text to fit into the view.

SizingView.swift
import SwiftUI
struct SizingView: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.darkBrown)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("Roses are red,")
                    Image("Rose")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("violets are blue, ")
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.darkBrown)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("I just love")
                    Image("Heart")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("coding with you!")
                }
            }
        }
        .font(.headline)
        .foregroundColor(.paleOrange)
    }
}

Preview
Two rounded rectangles stacked vertically where both have bolded text and an image.
Section 3
Refine the spacing and alignment of your views
Step 1

There are multiple ways to specify alignment in SwiftUI. One way is to specify the alignment inside HStack, VStack, or ZStack. The default alignment for a VStack is centered.

Experiment

Try adding in the alignment: .leading parameter to your VStack and see what happens.

Step 2

Adding the alignment: .leading parameter to your VStack aligns the books to the left edge of the screen. This is because the VStack is the container view and the images and shapes are subviews.

Step 3

A different way to add a row of books aligned to the right edge of the shelf is by adding a VStack and setting its alignment to .trailing.

Step 4

In vertical stacks, you can only set the horizontal alignment, like .leading or .trailing.

Note

In horizontal stacks you can only set the vertical alignment, like .top or .bottom.

Step 5

Another way to align books to the other side of the shelf is to use a frame modifier and specify the alignment.

Step 6

By setting the maxWidth to .infinity, you stretch the Image view horizontally until it fills the remaining space. Setting alignment parameter to .trailing makes the frame contents align to the .trailing edge.

Step 7

But wait, there’s more! You can also create space in a view with a Spacer.

Experiment

Add a yellow background color to the image next to the Spacer to visualize how much space it’s creating.

Step 8

Adding a Spacer inside an HStack causes the stack to expand to fill in any remaining horizontal space, and pushes the Image view to the .trailing edge.

Note

The Spacer only fills in the empty space in the HStack. On the contrary, if there is no space available for the spacer, it won’t render.

Step 9

You just learned about three different ways to align your views. Using the alignment parameter in the container view, adding a frame modifier with the alignment parameter and utilizing a Spacer are all great ways to align your views.

Tip

Different types of views and circumstances require different techniques. To learn more about the size and spacing of views, see Laying out a simple view.

Step 10

You can also specify the spacing as a parameter for the HStack. This changes the horizontal spacing between every subview inside the HStack.

Step 11

You can also add padding to the .trailing edge the image view to position it further from the edge.

Experiment

Explore other padding options such as .leading, .top, .bottom, .horizontal, and so on.

Step 12

You could add horizontal padding to every row of shelves and books, but that’s a lot of work and not easy to maintain. Instead, apply modifiers to the container view. In this case, the container is the VStack.

Tip

By applying the padding modifier to the VStack, you only have to add it once instead of adding it to every subview inside the VStack.

Step 13

However, if you want your bookshelf to have a specific width, use a frame instead of padding. Adding a border after the frame helps you visualize the frame.

Step 14

Woohoo! Now you have all the tools to create your own views.

AmazingAlignment.swift
import SwiftUI


struct AmazingAlignment: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 40))
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack(alignment: .trailing) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 10)
            }
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, alignment: .trailing)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
            HStack(spacing: 20) {
                Spacer()
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .background(Color.yellow)
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .padding(.trailing, 20)
            }
            .background(Color.mint)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
        }
        .padding(.horizontal)
        .frame(width: 250)
        .border(Color.black)
    }
}

Preview
a book shelf four rows of books with a border around them.
Section 4
Debugging views
Step 1

When your SwiftUI views don’t show up as you expect, you’ll need to flex your debugging skills to fix them. Start by looking at the view displayed in the preview — it’s clearly not showing up correctly! 😩 Can you guess what this view is supposed to be?

Step 2

It’s the queen of hearts playing card (or, it’s supposed to be 😵‍💫). As the name suggests, HalfCard contains half a card. You use two HalfCard instances in a VStack to create this view. Then, flip the bottom HalfCard upside down to form a mirror image of the top HalfCard. By combining the top and bottom halves, you create a full playing card.

Step 3

Any code applied to the HalfCard view affects both the top and bottom halves of the card, allowing you to fix issues in both halves at the same time.

Tip

Adding a border to a view is a great debugging tool because it allows you to see how much space a view occupies. You can use this technique to diagnose lots of issues in your code.

Step 4

The first major problem here is that all of the graphics are squished together. Add a frame in HalfCard and set the maxWidth and maxHeight to .infinity. This allows the frame to expand to fill any available space offered by the container, VStack.

Step 5

Even though the frame expanded, all of the graphics are still squished together. Add another border above the frame modifier. This allows you to see the outline of the VStack before you apply the frame.

Tip

You might wonder, why would it make a difference if you apply the border before or after the frame? This is because you actually produce a new view each time you apply a modifier, so the order that you apply them really matters. See Configuring views for more on this.

Step 6

Look at the difference in the blue and green borders. The blue border surrounds the squished graphics in the VStack, but doesn’t expand into the empty surrounding space of the green frame.

Experiment

Can you think of anyway to fix this so the contents of the VStack fill the entire frame?

Step 7

What if you switched up the order of the overlay and the frame? That would allow you to expand the frame first, which gives you extra space, then apply the overlay where it fits.

Step 8

Try removing the existing frame and add a new one right below the top-level VStack.

Step 9

There is just one more thing to fix. By default any content inside the frame is center-aligned. However, the crown at the center of the HalfCard needs to align to the bottom edge of HalfCard.

Experiment

Can you figure out a way to make this happen? Remember that you can add a border to visualize how much space your view needs and compare it to how you think the view should behave.

Step 10

There are two ways to align the crown to the bottom of your HalfCard view. You can add the alignment parameter to the frame– .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) Or, add a Spacer above the crown.

Step 11

Now that you have fixed the alignment in this card, you can remove any borders that you’ve added.

Step 12

Look at that beautiful playing card! The next time you’re unsure why your views aren’t displaying the way you want them to, don’t forget that you can add a border or background to help you debug issues with your views.

DebuggingViews.swift
import SwiftUI


struct HalfCard: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            VStack {
                Image(systemName: "crown.fill")
                    .font(.body)
                Text("Q")
                    .font(.largeTitle)
                Image(systemName: "heart.fill")
                    .font(.title)
            }
            .padding()
        }
    }
}


struct DebuggingView: View {
    var body: some View {
        VStack {
            HalfCard()
            HalfCard()
                .rotationEffect(.degrees(180))
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black)
        )
        .aspectRatio(0.70, contentMode: .fit)
        .foregroundColor(.red)
        .padding()
    }
}



Preview
queen of hearts red playing card.
Section 5
Bringing it all together
Step 1

Now that you’ve gone through all of the different parts for laying out a view, it’s time to bring them all together to see how you can use it when creating a view for a real app.

Step 2

Start by setting height of your card. There are many different ways to lay out a view and using .frame(minHeight:maxHeight:) is just one way you can set the height.

Tip

Setting the minHeight and maxHeight allows the view to scale for different screen sizes.

Step 3

Push the card title to the edge by setting the maximum height to .infinity.

Step 4

With the card title aligned, add padding to create space between the title of the view and the edge of the card. By adding padding to the VStack, you are applying padding to every view within the VStack.

Step 5

Having a .frame modifier with a maxWidth of .infinity stretches the Text view horizontally and fills the available space. The alignment parameter ensures that any content inside the frame aligns to the leading edge.

Step 6

You want the emojis to be in the middle of the view. To make sure they aren’t squished in the middle of the view, set the maxWidth to infinity.

Step 7

To add a gap between the circular buttons and the emojis you need to add padding below the text.

Step 8

You are now on your way to being a SwiftUI view layout expert!

Experiment

Try it out yourself by going to the Swift Playgrounds App to practice laying out views for a journal app!

MoodViewFull.swift
import SwiftUI


struct MoodViewFull: View {
    @Binding var value: String
    private let emojis = ["😢", "😴", "😁", "😡", "😐"]
    
    var body: some View {
        VStack {
            Text("What's your mood?")
                .foregroundColor(.darkBrown)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        value = emoji
                    } label: {
                        VStack {
                            Text(emoji)
                                .font(.system(size: 35))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom)
                            Image(systemName: value == emoji ? "circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundColor(.darkBrown)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}


Overview
SwiftUI provides a range of container views that group and repeat views. Use some containers purely for structure and layout, like stack views, lazy stack views, and grid views. Use others, like lists and forms, to also adopt system-standard visuals and interactivity.

Choosing the most appropriate container views for each part of your app’s user interface is an important skill to learn; it helps you with everything from positioning two views next to each other, to creating complex layouts with hundreds of elements.

Group collections of views
Stack views are the most primitive layout container available in SwiftUI. Use stacks to group collections of views into horizontal or vertical lines, or to stack them on top of one another.

Use HStack to lay out views in a horizontal line, VStack to position views in a vertical line, and ZStack to layer views on top of one another. Then, combine stack views to compose more complex layouts. These three kinds of stacks, along with their alignment and spacing properties, view modifiers, and Spacer views combine to allow extensive layout flexibility.

A diagram showing how a generic user profile layout might utilize stack views. The diagram shows the rendered layout next to an exploded, 3D illustration of the view hierarchy showing four layers of views stacked on top of each other. The lowest level of the hierarchy is a ZStack; above that is an Image view, then an HStack, and finally a VStack and Spacer view at the highest level.

You often use stack views as building blocks inside other container views. For example, a List typically contains stack views, with which you lay out views inside each row.

For more information on using stack views to lay out views, see Building layouts with stack views.

Repeat views or groups of views
You can also use HStack, VStack, LazyHStack, and LazyVStack to repeat views or groups of views. Place a stack view inside a ScrollView so your content can expand beyond the bounds of its container. Users can simultaneously scroll horizontally, vertically, or in both directions.

Stack views and lazy stacks have similar functionality, and they may feel interchangeable, but they each have strengths in different situations. Stack views load their child views all at once, making layout fast and reliable, because the system knows the size and shape of every subview as it loads them. Lazy stacks trade some degree of layout correctness for performance, because the system only calculates the geometry for subviews as they become visible.

A diagram showing how the system loads views on demand in a lazy stack view container.

When choosing the type of stack view to use, always start with a standard stack view and only switch to a lazy stack if profiling your code shows a worthwhile performance improvement. For more information on lazy stack views and how to measure your app’s view loading performance, see Creating performant scrollable stacks.

Position views in a two-dimensional layout
To lay out views horizontally and vertically at the same time, use a LazyVGrid or LazyHGrid. Grids are a good container choice to lay out content that naturally displays in square containers, like an image gallery. Grids are also a good choice to scale user interface layouts up for display on larger devices. For example, a directory of contact information might suit a list or vertical stack on an iPhone, but might fit more naturally in a grid layout when scaled up to a larger device like the iPad or Mac.

A diagram showing how a user interface might scale up from a device with a smaller screen, such as an iPhone onto a device with a larger screen, like a Mac.

Like stack views, SwiftUI grid views don’t inherently include a scrolling viewport; place them inside a ScrollView if the content might be larger than the available space.

Display and interact with collections of data
List views in SwiftUI are conceptually similar to the combination of a LazyVStack and ScrollView, but by default will include platform-appropriate visual styling around and between their contained items. For example, when running on iOS, the default configuration of a List adds separator lines between rows, and draws disclosure indicators for items which have navigation, and where the list is contained in a NavigationView.

List views also support platform-appropriate interactivity for common tasks such as inserting, reordering, and removing items. For example, adding the onDelete(perform:) modifier to a ForEach inside a List will enable system-standard swipe-to-delete interactivity.

Like LazyHStack and LazyVStack, rows inside a SwiftUI List also load lazily, and there is no non-lazy equivalent. Lists inherently scroll when necessary, and you don’t need to wrap them in a ScrollView.

Group views and controls for data entry
Use Form to build data-entry interfaces, settings, or preference screens that use system-standard controls.

A diagram showing a macOS preferences window, and an iOS settings screen next to each other. The screens both contain the same settings, but they use different, platform-appropriate controls.

Like all SwiftUI views, forms display their content in a platform-appropriate way. Be aware that the layout of controls inside a Form may differ significantly based on the platform. For example, a Picker control in a Form on iOS adds navigation, showing the picker’s choices on a separate screen, while the same Picker on macOS displays a pop-up button or set of radio buttons.



Views, structures, and properties
Customize views with properties
Create a SwiftUI app by building custom views to make a multiday weather forecast. In your custom view, you’ll use properties to customize the display for each day.

You design custom views using structures. Structures are a way to organize your code so that related pieces are packaged together. Every structure has a name that lets you reuse it like a template anywhere in your app. With structures, you can write code that is more efficient and has fewer errors.

Section 1
Create a project
Start by creating a project in Xcode.

Illustration of a phone screen with a globe above the words hello world.
Step 1

Launch Xcode. In the welcome window that appears, click Create New Project. (If Xcode is already running, you can choose File > New > Project.) In the following dialog, select the App template in the iOS tab and click Next.

Step 2

In the project settings dialog, enter “WeatherForecast” for the product name and “com.<yourname>” for the organization identifier (for example, “com.sophiesun”). Then, click Next.

Step 3

In the Save dialog, choose a location to save your project. Then, click Create.

Screenshot showing the Save dialog for a new project.
Section 2
Prototype a forecast view
Create a simple interface to display two weather forecasts. Notice the repeated pattern in the interface.

Illustration of the top half of the Weather Forecast app, showing two days' weather forecast, including the day, a colored weather symbol, a high temperature, and a low temperature.
Step 1

In ContentView, delete the code inside the VStack and replace it with a simple weather forecast.

Step 2

Add an Image view to your forecast and use it to display an SF Symbol of a sun.

This kind of Image requires one argument, whose argument label is systemName.

Step 3

To view the available SF Symbols, choose the Show Library button in the toolbar, then select the Show the Symbols Library button.

Note

You can also use the SF Symbols app.

Step 4

Use the .foregroundStyle modifier to make the sun icon yellow.

You use the .foregroundStyle modifier to apply a color to the foreground elements of any view. For example, setting a color as the foreground style of a Text view changes the color of the text.

Step 5

Get ready to add a second forecast by Control-clicking the VStack and choosing Embed in HStack.

An HStack is a container view that arranges views horizontally. A VStack arranges the views it contains vertically.

Note

There’s no change to the interface, because the HStack only contains one element.

Step 6

Copy the entire VStack, including the .padding modifier, and then paste the code below the first forecast to create a second forecast view. Update the data to display the next day’s forecast.

ContentView.swift
//
//  ContentView.swift
//  WeatherForecast
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        HStack {
            VStack {
                Text("Mon")
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Color.yellow)
                Text("High: 70")
                Text("Low: 50")
            }
            .padding()
            
            VStack {
                Text("Tue")
                Image(systemName: "cloud.rain.fill")
                    .foregroundStyle(Color.blue)
                Text("High: 60")
                Text("Low: 40")
            }
            .padding()
        }
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot showing two vertical stacks side by side. The first stack has the text, Mon; then a yellow sun icon; then the text, High: 70; then the text, Low: 50. The second stack has the text, Tue; then a blue rain icon; then the text, High: 60; then the text, Low: 40.
Section 3
Create a custom subview
Instead of continuing to copy and paste your code, learn how to encapsulate a day’s forecast in its own structure to make a customizable forecast card.

Illustration of the top half of the Weather Forecast app, showing two days' weather forecast with the same content: the text, Mon; then a yellow sun icon; then the text, High: 70; then the text, Low: 50.
Step 1

Between the ContentView and the preview, declare a structure named DayForecast in the same manner as ContentView.

Note

You define — or declare — a structure using the struct keyword.

Step 2

Move the VStack for the first day’s forecast into the body of DayForecast.

You don’t see Monday’s weather in the preview because ContentView doesn’t contain DayForecast.

Step 3

Create an instance of the DayForecast structure by typing its name followed by parentheses. Display the structure as a subview of ContentView.

Note

A subview is a view used inside another view. For example, in the default code for a new project, Text and Image are subviews of ContentView.

Step 4

Replace the second forecast with another DayForecast view.

Now that you’ve created a DayForecast view, you can use it for each day’s forecast instead of repeating the code.

Step 5

Examine your code. There are three places where you reference DayForecast. Inside the HStack, you’re creating two instances of DayForecast to display on the screen. At the bottom, you’re defining the view and its contents.

ContentView.swift
//
//  ContentView.swift
//  WeatherForecast
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        HStack {
            DayForecast()
            
            DayForecast()
        }
    }
}


struct DayForecast: View {
    var body: some View {
        VStack {
            Text("Mon")
            Image(systemName: "sun.max.fill")
                .foregroundStyle(Color.yellow)
            Text("High: 70")
            Text("Low: 50")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot showing two vertical stacks side by side. Both stacks have the same content: the text, Mon; then a yellow sun icon; then the text, High: 70; then the text, Low: 50.
Section 4
Generalize the day with a property
You can use properties to display any forecast data using your custom view. Start by making the day of the week customizable.

Illustration of the top half of the Weather Forecast app, showing two days' weather forecast with almost the same content: the text, Mon and Tue; then a yellow sun icon; then the text, High: 70; then the text, Low: 50.
Step 1

Add a property to the DayForecast view to store data about the day of the week. Add a blank line between the property and the body property below it.

You can use blank lines in Swift to make your code more readable; they have no impact on the way your code runs.

Note

Xcode displays an error, which you’ll fix in a moment.

Step 2

Before you fix the error, take a look at the property you just created.

To declare a property, use the let keyword. A property has a name, followed by a colon and then the kind of data it holds. This property’s name is day, and it holds a String.

Note

In Swift, kinds of data are called types. You can read the code you added to the DayForecast structure like this: “day is a property whose type is String.” Or you could say, “day is a property of type String.”

Step 3

Look at the error where you first use DayForecast: “Missing argument for parameter ‘day’ in call.” Click the icon next to the error message in Xcode to expand it.

When you add a property to a structure, you need to give it a value every time you create an instance of the structure. This error means that you haven’t given the day property a value.

Step 4

Click the Fix button in the error banner to add the argument label, day:.

Step 5

Replace the placeholder with a day of the week in quotation marks.

You’re calling the initializer for DayForecast and passing a String argument for the day parameter.

Step 6

Fix the second error in the same way, using a different day for the argument.

The preview doesn’t change, because you’re still passing the string literal "Mon" into the first Text view in the DayForecast structure.

Step 7

Use the day property in the Text view of your DayForecast structure so your preview reflects the data you added above.

The day property holds a String value. By using the property as an argument, you’re passing its value into the Text view.

Step 8

Take a look at how the string value journeys from your ContentView code into an instance of DayForecast and from there to your interface.

You’ve generalized DayForecast to display the name of any day.

Diagram illustrating how the text written into each instance of DayForecast gets passed around. First as an argument in the initializer of DayForecast; next, as the value of the property, day, in the DayForecast structure; finally, as a Text view that appears in the preview.
Section 5
Use Int to display temperatures
Generalize the temperature range display in DayForecast. Add properties to represent temperatures as numbers — using a new type, Int — then, use string interpolation to display the temperatures in a Text view.

Illustration of the top half of the Weather Forecast app, showing two days' weather forecast with similar content: The first stack has the text, Mon; then a yellow sun icon; then the text, High: 70; then the text, Low: 50. The second stack has the text, Tue; then a yellow sun icon; then the text, High: 60; then the text, Low: 40.
Step 1

Store the high and low temperatures as Int properties in DayForecast. Int is a data type that represents a whole number.

You get errors like you did when you added the day property, because your DayForecast initializers are now missing arguments.

Step 2

Fix the errors by updating the two instances of DayForecast with temperature data. When there are two or more arguments, you separate them using commas.

As before, the preview won’t change until you use the new properties in the DayForecast structure.

Step 3

In DayForecast, update the Text view initializers for the two temperature values.

You get another error, “No exact matches in call to initializer,” because there’s no way to initialize a Text view with a numeric value. You need a way to convert a number to a string to pass into the Text initializer. You can use string interpolation to do just that.

Step 4

Change the Int values in the Text initializers to string literals, using interpolation to insert the values of your two temperature properties.

If you want to display the value of a number in a text view, which expects a String, you have to change the number into a string, which you do like this: "\(number)".

Step 5

Update your Text view initializers to include the high and low labels before the temperatures.

Experiment

Try changing the text in the string surrounding the interpolation of the temperature. For example, you can type a degree sign (º) using Option-0.

ContentView.swift
//
//  ContentView.swift
//  WeatherForecast
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        HStack {
            DayForecast(day: "Mon", high: 70, low: 50)
            
            DayForecast(day: "Tue", high: 60, low: 40)
        }
    }
}


struct DayForecast: View {
    let day: String
    let high: Int
    let low: Int
    
    var body: some View {
        VStack {
            Text(day)
            Image(systemName: "sun.max.fill")
                .foregroundStyle(Color.yellow)
            Text("High: \(high)")
            Text("Low: \(low)")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot showing two vertical stacks side by side. The first stack has the text, Mon; then a yellow sun icon; then the text, High: 70; then the text, Low: 50. The second stack has the text, Tue; then a yellow sun icon; then the text, High: 60; then the text, Low: 40.
Section 6
Use computed properties for the icon and color
Add another property that uses a Boolean, a value that is either true or false, to compute what appears in the image view. Show a rain cloud if the value is true and a sun if it’s false.

Illustration of the top half of the Weather Forecast app, showing two days' weather forecast with different content. The first says Mon, has a yellow sun, a high of 70, and a low of 50. The second says Tue, has a blue rain cloud, a high of 60 and a low of 40.
Step 1

Add a Boolean property to DayForecast to represent rain conditions.

You’ll fix the errors in the next step.

Step 2

Use the Fix button to update the instances of DayForecast in your ContentView code. Pass in true or false values for the new isRainy parameter.

The order of parameters in the initializer matches the order of declaration of their matching properties, so you can’t add the new arguments at the end, as you did before.

Step 3

Because the isRainy property is a Bool, you need to write code for what to do when the value is true and when it’s false. To do this, create a computed property that represents the icon’s name.

A computed property doesn’t store a value directly like the stored properties you declared earlier using let. Computed properties use the var keyword because their value may vary depending on the results of the computation.

Step 4

Examine the error in your new computed property.

Code that computes a value must provide the value using the return keyword. (Accessor is another name for a computed property.)

Step 5

Use the return keyword to return the name for the rain icon.

Experiment

Try removing the return keyword. Swift encourages programmers to remove the return keyword if the code is simple enough. You can choose whether to include the keyword to remind yourself of the function of the code or to remove it for conciseness.

Step 6

Replace the string literal "sun.max.fill" in the Image initializer with a reference to your new iconName computed property.

Now you have two yellow rainclouds. You need to use the value of isRainy to return different values.

Step 7

Delete the single return statement in the computed property, then add an if/else statement to return the correct icon name based on the value of the isRainy property.

If the condition is true, Swift executes the code in the braces following the if. If the condition is false, Swift executes the code in the braces following the else keyword.

Tip

Like the simple return statement, you can choose to remove the return keywords in the if/else statement.

Step 8

The color of the icon also depends on the isRainy property, so you can follow the same pattern to create a second computed property for the icon color. Use another if/else statement to return the correct color depending on the weather condition. Then, replace the Color.yellow value in the .foregroundStyle modifier with a reference to iconColor.

You’ve encapsulated the full expressiveness of a forecast card in a custom view. Add one or two more cards to see how easy it is to make new ones.

ContentView.swift
//
//  ContentView.swift
//  WeatherForecast
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        HStack {
            DayForecast(day: "Mon", isRainy: false, high: 70, low: 50)
            
            DayForecast(day: "Tue", isRainy: true, high: 60, low: 40)
        }
    }
}


struct DayForecast: View {
    let day: String
    let isRainy: Bool
    let high: Int
    let low: Int
    
    var iconName: String {
        if isRainy {
            return "cloud.rain.fill"
        } else {
            return "sun.max.fill"
        }
    }
    
    var iconColor: Color {
        if isRainy {
            return Color.blue
        } else {
            return Color.yellow
        }
    }
    
    var body: some View {
        VStack {
            Text(day)
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
            Text("High: \(high)")
            Text("Low: \(low)")
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

Preview
Screenshot showing two vertical stacks side by side. The first stack has the text, Mon; then a yellow sun icon; then the text, High: 70; then the text, Low: 50. The second stack has the text, Tue; then a blue raincloud icon; then the text, High: 60; then the text, Low: 40.
Section 7
Style the custom view
Now that you’ve made a custom subview for a forecast card, you can easily adjust the style, font, and padding of its elements and see the changes in every card.

Illustration of the top half of the Weather Forecast app, showing two days' weather forecast, including the day, a colored weather symbol, a high temperature, and a low temperature. The days and high temperatures are in bold font, and the colored weather symbols are large and have space above and below them.
Step 1

In the body of your DayForecast view, add a line below Text(day). Then, begin typing .font and pause to let Xcode display code completion suggestions.

Step 2

Choose font(_ font:) from the code completion suggestions and press Return to insert it into your code. Then, type to replace the highlighted placeholder with Font.headline.

Some code completion suggestions, like caption and title, are semantic values: Their names indicate how the fonts should be used in your app.

Experiment

Try using different values for the .font modifier.

Step 3

Use .font(Font.largeTitle) to increase the size of the image.

Because SF Symbols are often used in conjunction with text, you can adjust their size using semantic font names. They’re designed to work at many different sizes and weights.

Note

SF Symbols work automatically with Dynamic Type, so they scale appropriately when people adjust the text size on their device.

Step 4

Use the .fontWeight modifier to change the weights of the high and low temperatures. Experiment with different weights from the code completion suggestions.

The .fontWeight modifier changes the weight of a font without affecting its semantic meaning (the way using .body or .headline would).

Step 5

Use the secondary system color for the low temperature.

You use the secondary color for less-important information.

Step 6

Finally, add a little padding to the icon.

Experiment

Add your own style to the project, editing the look and colors until you’re satisfied.

ContentView.swift
//
//  ContentView.swift
//  WeatherForecast
//
//
//


import SwiftUI


struct ContentView: View {
    var body: some View {
        HStack {
            DayForecast(day: "Mon", isRainy: false, high: 70, low: 50)
            
            DayForecast(day: "Tue", isRainy: true, high: 60, low: 40)
        }
    }
}


struct DayForecast: View {
    let day: String
    let isRainy: Bool
    let high: Int
    let low: Int
    
    var iconName: String {
        if isRainy {
            return "cloud.rain.fill"
        } else {
            return "sun.max.fill"
        }
    }
    
    var iconColor: Color {
        if isRainy {
            return Color.blue
        } else {
            return Color.yellow
        }
    }
    
    var body: some View {
        VStack {
            Text(day)
                .font(Font.headline)
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(Font.largeTitle)
                .padding(5)
            Text("High: \(high)")
                .fontWeight(Font.Weight.semibold)
            Text("Low: \(low)")
                .fontWeight(Font.Weight.medium)
                .foregroundStyle(Color.secondary)
        }
        .padding()