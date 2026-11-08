#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
ROOT_DIR="$PWD"
APP="build/GPUObserver.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/Icon.iconset dist
cp assets/Info.plist "$APP/Contents/Info.plist"
swiftc -O -module-name GPUObserver -file-prefix-map "$ROOT_DIR=/build" -debug-prefix-map "$ROOT_DIR=/build" -file-compilation-dir /build src/main.swift -o "$APP/Contents/MacOS/GPUObserver"
"$APP/Contents/MacOS/GPUObserver" --make-icon "$ROOT_DIR/build/icon.png"
for size in 16 32 128 256 512; do
 sips -z "$size" "$size" build/icon.png --out "build/Icon.iconset/icon_${size}x${size}.png" >/dev/null
 doubled=$((size * 2))
 sips -z "$doubled" "$doubled" build/icon.png --out "build/Icon.iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns build/Icon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
cp LICENSE "$APP/Contents/Resources/LICENSE.txt"
codesign --force --sign - "$APP"
codesign --verify --deep --strict "$APP"
mkdir -p build/dmg
# ditto updates an existing staging bundle when building again.
ditto "$APP" build/dmg/GPUObserver.app
ln -sfn /Applications build/dmg/Applications
hdiutil create -volname GPUObserver -srcfolder build/dmg -ov -format UDZO dist/GPUObserver-macOS-x86_64.dmg
(cd dist && shasum -a 256 GPUObserver-macOS-x86_64.dmg > SHA256SUMS.txt)
