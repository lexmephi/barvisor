# Barvisor

**Barvisor** is a small macOS menu bar app that lets you show or hide the menu bar in fullscreen mode — per application, not globally.

macOS hides the menu bar by default when an app goes fullscreen. There's no system setting for individual apps, but under the hood every app has a hidden `AppleMenuBarVisibleInFullscreen` preference. Barvisor is a convenient wrapper around this preference for the currently active app.

## Features

- 🖱 Lives in the menu bar, takes no space in the Dock.
- 🎯 Works with whichever app is currently in focus.
- 🔁 Toggles menu bar visibility in fullscreen for a specific app, without affecting others.
- 🪶 Requires no Accessibility permissions.

## Requirements

- macOS 12.0 (Monterey) or newer.
- Apple Silicon (arm64) or Intel (x86_64) — builds are universal.

## Installation

### Prebuilt build

1. Download the `Barvisor.app` archive from the [Releases](../../releases) page.
2. Unzip and drag `Barvisor.app` into the Applications folder.
3. On first launch macOS may block the app since it's signed with an ad-hoc developer certificate. To open it:
   - right-click `Barvisor.app` and select **Open**;
   - confirm the launch in the dialog that appears.
   After the first confirmation the app will open as usual.

### Build from source

```bash
git clone <repo-url> barvisor
cd barvisor

# Native arch only (Command Line Tools are enough):
./build-app.sh

# Universal binary arm64 + x86_64 (requires full Xcode):
./build-app.sh --universal
```

The finished bundle appears in `build/Barvisor.app`. Run it:

```bash
open build/Barvisor.app
```

## How to use

1. Barvisor launches as an icon in the menu bar (the menu bar rectangle symbol).
2. Switch to the app whose fullscreen menu bar behavior you want to change.
3. Open the Barvisor menu. It automatically adapts to the active app and shows:
   - the app name;
   - the current state ("visible", "hidden", or "not set — hidden by default");
   - a toggle button (show / hide);
   - an **Apply — restart the app** item;
   - **Quit**.
4. Click **show / hide** — the preference is written.
5. Click **Apply — restart the app** — Barvisor restarts the target app so the change takes effect.

> **Important:** the `AppleMenuBarVisibleInFullscreen` preference applies **only after restarting** the app. Simply exiting and re-entering fullscreen isn't enough — that's why Barvisor offers to restart the app. Restarting closes the app, so save any unsaved data first.

## Permissions

On first applying a change, macOS may prompt for permission to **control other apps** (Apple Events). This is needed so Barvisor can correctly restart the target app. The permission can be granted or revoked later in **System Settings → Privacy & Security → Automation**.

## Privacy

Barvisor runs locally and sends data nowhere. It only reads and writes the `AppleMenuBarVisibleInFullscreen` preference for the selected app via system APIs (`CFPreferences`).

## License

Distributed under the [GNU GPLv3](LICENSE) license.
