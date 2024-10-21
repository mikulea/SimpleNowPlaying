import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @AppStorage("maxCharsTitle") private var maxCharsTitle: Int = 24
    @AppStorage("maxCharsArtist") private var maxCharsArtist: Int = 24

    var mediaObserver: MediaManager!
    var statusItem: NSStatusItem!
    var statusMenu: NSMenu!
    var settingsWindow: SettingsWindow!
    var popover: NSPopover!
    var cancellables = Set<AnyCancellable>()

    @objc func togglePopover(_ sender: NSStatusBarButton?) {

        guard let statusBarButton = sender else { return }

        if statusItem.button != nil {
            if popover.isShown {
                popover.performClose(statusBarButton)
            } else {
                popover.show(
                    relativeTo: statusBarButton.bounds, of: statusBarButton,
                    preferredEdge: .minY)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }

    @objc func didClickStatusBarItem(_ sender: AnyObject?) {

        guard let event = NSApp.currentEvent else { return }

        switch event.type {
        case .rightMouseUp:
            statusItem.menu = statusMenu
            statusItem.button?.performClick(nil)
        case .leftMouseUp:
            togglePopover(statusItem.button)
        default:
            print("fuck off")
        }
    }

    func menuDidClose(_: NSMenu) {
        statusItem.menu = nil
    }

    private func updateStatusItemTitle(_ title: String, _ artist: String) {

        var parsedTitle: String? = nil
        var parsedArtist: String? = nil

        if title.count > maxCharsTitle {
            parsedTitle = title.prefix(maxCharsTitle) + "."
        }

        if artist.count > maxCharsArtist {
            parsedArtist = artist.prefix(maxCharsArtist) + "..."
        }

        statusItem.button?.title =
            "\(parsedTitle != nil ? parsedTitle! : title) - \(parsedArtist != nil ? parsedArtist! : artist)"
    }

    private func setupContentView() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(mediaObserver))
        popover.contentViewController?.view.window?.makeKey()
    }

    @objc func showSettings(_ sender: AnyObject?) {

        if settingsWindow == nil {
            settingsWindow = SettingsWindow()
            let hostedPrefView = NSHostingView(
                rootView: PreferencesView(parentWindow: settingsWindow))

            settingsWindow.contentView = hostedPrefView
        }

        settingsWindow.center()
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    private func setupStatusBar() {

        statusMenu = NSMenu()
        statusMenu.delegate = self
        statusMenu.addItem(
            withTitle: "Settings",
            action: #selector(showSettings),
            keyEquivalent: "")
        statusMenu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate),
            keyEquivalent: "")

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.action = #selector(didClickStatusBarItem)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        mediaObserver.$title
            .combineLatest(mediaObserver.$artist)
            .sink { [weak self] title, artist in
                self?.updateStatusItemTitle(title, artist)
            }
            .store(in: &cancellables)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.mediaObserver = MediaManager()!

        setupContentView()
        setupStatusBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        cancellables.removeAll()
    }
}
