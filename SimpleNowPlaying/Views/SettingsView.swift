import AppKit
import Foundation
import SwiftUI
import LaunchAtLogin

class SettingsWindow: NSWindow {

    init() {
        super.init(
            contentRect: NSRect(
                x: 0, y: 0, width: SETTINGS_WINDOW_MAX_WIDTH,
                height: SETTINGS_WINDOW_MAX_HEIGHT),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false)

        self.titlebarAppearsTransparent = false
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
        self.title = "SimpleNowPlaying"

    }
}

struct PreferencesView: View {

    private weak var parentWindow: SettingsWindow!

    @AppStorage("maxCharsTitle") private var maxCharsTitle: Int = 24
    @AppStorage("maxCharsArtist") private var maxCharsArtist: Int = 24
    @AppStorage("alternateTitleArtist") private var alternateTitleArtist: Bool =
        false
    @AppStorage("Swap Artist/Title position") private var swapTitleArtist:
        Bool = false

    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false

    init(parentWindow: SettingsWindow) {
        self.parentWindow = parentWindow

    }

    // MARK: - Main Body
    var body: some View {
        VStack(alignment: .leading) {
            Text("Appearance")
                .font(.title2)
                .fontWeight(.semibold)
            HStack(alignment: .center) {
                Text("Title Character Limit")
                Slider(
                    value: Binding(
                        get: { Double(maxCharsTitle) },
                        set: { newValue in
                            maxCharsTitle = Int(newValue)
                        }
                    ), in: 10...48)
                Text("\(maxCharsTitle)") 
                    .font(.callout)
            }
            HStack(alignment: .center) {
                Text("Artist Character Limit")
                Slider(
                    value: Binding(
                        get: { Double(maxCharsArtist) },
                        set: { newValue in
                            maxCharsArtist = Int(newValue)
                        }
                    ), in: 10...48)
                Text("\(maxCharsArtist)")  // Displays the current value
                    .font(.callout)
            }
            Text(
                "The number of characters allowed in the title and artist fields before truncation."
            )

            Divider()

            Toggle("Use Alternate Title/Artist", isOn: $alternateTitleArtist)
                .toggleStyle(.checkbox)  // Makes it look like a checkbox
            Text(
                "When this is enabled, if the title contains a \"-\" character, the artist will be replaced with whatever is on the other side of the character. For example, if the title is \"Sewerslvt - Blacklight\", the title would be \"Blacklight\" and the artist would be \"Sewerslvt\". \nThis is useful for playing music from repost channels or 3rd party sources."
            )
            .font(.subheadline)
            Toggle("Swap Artist and Title position", isOn: $swapTitleArtist)
                .toggleStyle(.checkbox)
            LaunchAtLogin.Toggle()

        }
        .padding()
        .frame(
            maxWidth: SETTINGS_WINDOW_MAX_WIDTH,
            maxHeight: SETTINGS_WINDOW_MAX_HEIGHT, alignment: .topLeading)

        Spacer()

        Divider()
        HStack(alignment: .center) {
            Text("Links:")
                .font(.headline)
            Link("GitHub (send bugs here)", destination: LINKS_GITHUB)
            Link("Twitter", destination: LINKS_TWITTER)
            Spacer()
        }
        .offset(x: 8, y: -3)  //it looked weird

    }

}
