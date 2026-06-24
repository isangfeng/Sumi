#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/.build/Sumi.app"
DIST_DIR="$ROOT_DIR/.build/dist"
DMG_PATH="$DIST_DIR/Sumi.dmg"
STAGING_DIR="$DIST_DIR/dmg-root"
ARCH_BUILD_DIR="$ROOT_DIR/.build/release-architectures"
UNIVERSAL_DIR="$ROOT_DIR/.build/universal/release"
UNIVERSAL_EXECUTABLE="$UNIVERSAL_DIR/Sumi"

DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

cd "$ROOT_DIR"

rm -rf "$ARCH_BUILD_DIR" "$UNIVERSAL_DIR"

swift build -c release --product Sumi --triple x86_64-apple-macosx14.0 --scratch-path "$ARCH_BUILD_DIR/x86_64"
swift build -c release --product Sumi --triple arm64-apple-macosx14.0 --scratch-path "$ARCH_BUILD_DIR/arm64"

mkdir -p "$UNIVERSAL_DIR"
lipo -create \
  "$ARCH_BUILD_DIR/x86_64/x86_64-apple-macosx/release/Sumi" \
  "$ARCH_BUILD_DIR/arm64/arm64-apple-macosx/release/Sumi" \
  -output "$UNIVERSAL_EXECUTABLE"

SUMI_EXECUTABLE="$UNIVERSAL_EXECUTABLE" "$ROOT_DIR/scripts/make-app-bundle.sh" >/dev/null

rm -rf "$DIST_DIR"
mkdir -p "$STAGING_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/Sumi.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "Sumi" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" \
  >/dev/null

echo "$DMG_PATH"
