import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = StatusItemController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.start()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // LSUIElement-equivalent: no Dock icon.
app.run()
