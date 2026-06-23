#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/.build/MarkdownStudio.app"
DIST_DIR="$ROOT_DIR/.build/dist"
DMG_PATH="$DIST_DIR/MarkdownStudio.dmg"
STAGING_DIR="$DIST_DIR/dmg-root"

DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

cd "$ROOT_DIR"

swift build -c release
"$ROOT_DIR/scripts/make-app-bundle.sh" >/dev/null

rm -rf "$DIST_DIR"
mkdir -p "$STAGING_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/MarkdownStudio.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "MarkdownStudio" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" \
  >/dev/null

echo "$DMG_PATH"
