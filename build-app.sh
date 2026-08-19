#!/bin/bash
set -euo pipefail

APP_NAME="MenubarVis"
APP_BUNDLE="build/$APP_NAME.app"

echo "→ Building with SwiftPM…"
swift build -c release

EXE="$(swift build -c release --show-bin-path)/$APP_NAME"

echo "→ Assembling .app bundle…"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$EXE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "✓ Built: $APP_BUNDLE"
echo "  Run with: open '$APP_BUNDLE'"
