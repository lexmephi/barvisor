import Foundation

/// Reads / writes the `AppleMenuBarVisibleInFullscreen` preference on a
/// per-application basis using the user defaults / CFPreferences API.
enum DefaultsController {

    private static let key = "AppleMenuBarVisibleInFullscreen" as CFString

    /// Current value for the given application. `nil` means "not set"
    /// (macOS treats unset as "hidden in fullscreen").
    static func read(bundleIdentifier: String) -> Bool? {
        let value = CFPreferencesCopyAppValue(key, bundleIdentifier as CFString)
        return value as? Bool
    }

    /// Writes the value for the application and flushes it to disk.
    static func write(bundleIdentifier: String, value: Bool) {
        CFPreferencesSetAppValue(key, NSNumber(value: value), bundleIdentifier as CFString)
        CFPreferencesAppSynchronize(bundleIdentifier as CFString)
    }
}
