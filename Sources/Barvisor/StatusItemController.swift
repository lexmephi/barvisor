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

        let appName = app?.localizedName ?? "Нет активного приложения"
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
                ? "Меню-бар в фуллскрине: видимый"
                : "Меню-бар в фуллскрине: скрытый"
        } else {
            currentState = false
            stateTitle = "Меню-бар в фуллскрине: не задано (по умолч. скрыт)"
        }
        let stateItem = NSMenuItem(title: stateTitle, action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())

        // Toggle
        let toggleTitle = currentState
            ? "Скрыть меню-бар в фуллскрине"
            : "Показать меню-бар в фуллскрине"
        let toggle = NSMenuItem(title: toggleTitle, action: #selector(toggleCurrent), keyEquivalent: "")
        toggle.target = self
        toggle.isEnabled = (app != nil)
        menu.addItem(toggle)
        menu.addItem(.separator())

        // Apply via app restart
        let restartItem = NSMenuItem(title: "Применить — перезапустить приложение",
                                     action: #selector(applyViaRestart), keyEquivalent: "")
        restartItem.target = self
        restartItem.isEnabled = (app != nil)
        menu.addItem(restartItem)
        menu.addItem(.separator())

        // Quit
        let quit = NSMenuItem(title: "Выход", action: #selector(quit), keyEquivalent: "q")
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
