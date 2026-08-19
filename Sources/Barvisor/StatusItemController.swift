import AppKit

/// Owns the menu bar status item and builds a context-aware menu for the
/// frontmost application every time the menu is opened.
final class StatusItemController: NSObject, NSMenuDelegate {

    private let statusItem: NSStatusItem
    private var frontmostApp: NSRunningApplication?

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
    }

    func start() {
        if let button = statusItem.button {
            let symbol = NSImage(systemSymbolName: "menubar.rectangle",
                                 accessibilityDescription: "Barvisor")
            if let symbol {
                button.image = symbol
            } else {
                button.title = "▦"
            }
        }
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        statusItem.menu = menu
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        rebuild(menu: menu)
    }

    // MARK: - Build menu

    private func rebuild(menu: NSMenu) {
        menu.removeAllItems()

        let app = NSWorkspace.shared.frontmostApplication
        frontmostApp = app

        let appName = app?.localizedName ?? "No active application"
        let bundleId = app?.bundleIdentifier ?? "—"
        let raw = (bundleId != "—") ? DefaultsController.read(bundleIdentifier: bundleId) : nil

        // Header: app name
        let header = NSMenuItem(title: appName, action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        // Current state
        let currentState: Bool
        let stateTitle: String
        if let value = raw {
            currentState = value
            stateTitle = value
                ? "Menu bar in fullscreen: visible"
                : "Menu bar in fullscreen: hidden"
        } else {
            currentState = false
            stateTitle = "Menu bar in fullscreen: not set (hidden by default)"
        }
        let stateItem = NSMenuItem(title: stateTitle, action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())

        // Toggle
        let toggleTitle = currentState
            ? "Hide menu bar in fullscreen"
            : "Show menu bar in fullscreen"
        let toggle = NSMenuItem(title: toggleTitle, action: #selector(toggleCurrent), keyEquivalent: "")
        toggle.target = self
        toggle.isEnabled = (app != nil)
        menu.addItem(toggle)
        menu.addItem(.separator())

        // Apply via app restart
        let restartItem = NSMenuItem(title: "Apply — restart the app",
                                     action: #selector(applyViaRestart), keyEquivalent: "")
        restartItem.target = self
        restartItem.isEnabled = (app != nil)
        menu.addItem(restartItem)
        menu.addItem(.separator())

        // Quit
        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    // MARK: - Actions

    @objc private func toggleCurrent() {
        guard let app = frontmostApp, let bundleId = app.bundleIdentifier else { return }
        let current = DefaultsController.read(bundleIdentifier: bundleId) ?? false
        DefaultsController.write(bundleIdentifier: bundleId, value: !current)
    }

    @objc private func applyViaRestart() {
        guard let app = frontmostApp else { return }
        let bundleUrl = app.bundleURL
        app.terminate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard let url = bundleUrl else { return }
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        }
    }

    @objc private func quit() {
        NSApp.terminate(self)
    }
}
