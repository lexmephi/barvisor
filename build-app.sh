#!/bin/bash
set -euo pipefail

APP_NAME="Barvisor"
APP_BUNDLE="build/$APP_NAME.app"

if [[ "${1:-}" == "--universal" ]]; then
  # Universal binary (arm64 + x86_64) — requires full Xcode (not just CLT).
  echo "→ Building universal (arm64 + x86_64) release binary…"
  swift build -c release --arch arm64 --arch x86_64
  BIN_PATH="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"
else
  echo "→ Building release binary (native arch)…"
  swift build -c release
  BIN_PATH="$(swift build -c release --show-bin-path)"
fi
EXE="$BIN_PATH/$APP_NAME"

echo "→ Assembling .app bundle…"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$EXE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "→ Ad-hoc signing…"
codesign --force --sign - "$APP_BUNDLE"

echo "✓ Built: $APP_BUNDLE"
echo "  Run with: open '$APP_BUNDLE'"
