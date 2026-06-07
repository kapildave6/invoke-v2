#!/bin/bash
#
# Build a real, code-signed Invoke.app from the SwiftPM package.
#
#   scripts/build-app.sh                  # release build, ad-hoc signed (stable bundle identity)
#   INVOKE_SIGN_IDENTITY="Developer ID Application: …" scripts/build-app.sh   # Developer ID + hardened runtime
#
# Why this matters (PLAN §3.4/§8.5): a stable signed bundle stops macOS re-prompting for Keychain and
# Accessibility on every rebuild, registers the invoke:// URL scheme (deep links), and gives a real
# Finder icon. Output: apps/macos/.build/Invoke.app
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$ROOT/apps/macos"
CONFIG="${INVOKE_BUILD_CONFIG:-release}"
APP="$PKG/.build/Invoke.app"
IDENTITY="${INVOKE_SIGN_IDENTITY:--}"   # "-" = ad-hoc

echo "▸ swift build ($CONFIG)…"
swift build --package-path "$PKG" -c "$CONFIG" --product invoke

BUILD_DIR="$PKG/.build/$CONFIG"
EXE="$BUILD_DIR/invoke"
RESBUNDLE="$BUILD_DIR/Invoke_InvokeShell.bundle"
ICON="$PKG/Sources/InvokeShell/Resources/AppIcon.icns"
[ -x "$EXE" ] || { echo "✗ executable not found at $EXE"; exit 1; }

echo "▸ assembling ${APP}…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$EXE" "$APP/Contents/MacOS/invoke"
cp "$PKG/Resources/Info.plist" "$APP/Contents/Info.plist"
# Bake the dev repo path so the bundle (whose cwd is "/") can find node_modules / runtime / examples.
/usr/libexec/PlistBuddy -c "Add :INVOKERepoRoot string $ROOT" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :INVOKERepoRoot $ROOT" "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"
[ -f "$ICON" ] && cp "$ICON" "$APP/Contents/Resources/AppIcon.icns"
# Bundle.module for InvokeShell resolves via Bundle.main.resourceURL (Contents/Resources) for an app,
# so the SwiftPM resource bundle goes there. (Not in MacOS/ — that dir is Mach-O only and codesign
# rejects a nested bundle there.)
if [ -d "$RESBUNDLE" ]; then
  cp -R "$RESBUNDLE" "$APP/Contents/Resources/"
fi

echo "▸ codesign (identity: $IDENTITY)…"
if [ "$IDENTITY" = "-" ]; then
  codesign --force --deep --sign - "$APP"
else
  codesign --force --deep --options runtime --timestamp --sign "$IDENTITY" "$APP"
fi
codesign --verify --verbose=2 "$APP" 2>&1 | sed 's/^/  /' || true

echo "✓ built $APP"
echo "  run:   open \"$APP\""
echo "  (Developer ID + notarization for distribution: set INVOKE_SIGN_IDENTITY.)"
