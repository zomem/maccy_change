#!/usr/bin/env bash
set -euo pipefail

# Rebuild and run Maccy (menu bar app) in Debug without code signing.
# - Uses a fresh DerivedData each time to avoid stale artifacts.
# - Falls back to the last successful build if the new build misses the executable.

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$ROOT_DIR"

DERIVED_DATA="build-run-$(date +%s)"
APP_NAME="Maccy.app"
PRODUCT_DIR="$DERIVED_DATA/Build/Products/Debug"
APP_PATH="$PRODUCT_DIR/$APP_NAME"
EXECUTABLE="$APP_PATH/Contents/MacOS/Maccy"

echo "Killing any running instance…"
osascript -e 'tell application id "org.p0deje.Maccy" to quit' >/dev/null 2>&1 || true
pkill -f 'Maccy.app/Contents/MacOS/Maccy' >/dev/null 2>&1 || true

echo "Cleaning and building (Debug, no codesign) → $DERIVED_DATA …"
xcodebuild \
  -project Maccy.xcodeproj \
  -scheme Maccy \
  -configuration Debug \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  clean build

if [[ -x "$EXECUTABLE" ]]; then
  SELECTED_APP="$APP_PATH"
else
  echo "Executable missing in fresh build (likely Xcode quirk). Falling back to last good build…"
  SELECTED_APP="$(ls -t */Build/Products/Debug/$APP_NAME 2>/dev/null | \
    xargs -I{} bash -c '[[ -x "{}/Contents/MacOS/Maccy" ]] && echo {}' | head -n1 || true)"
  if [[ -z "$SELECTED_APP" ]]; then
    echo "No previous good build found. Aborting." >&2
    exit 1
  fi
fi

echo "Launching: $SELECTED_APP"
open "$SELECTED_APP"
sleep 1

echo "Processes:"
pgrep -lf Maccy || true

echo "Bundle ID:"
osascript -e 'id of app "Maccy"' || true

echo "Note: Maccy 是菜单栏应用。用 ⌘⇧C 呼出；首次运行需在“系统设置 → 隐私与安全 → 辅助功能”允许 Maccy。"

