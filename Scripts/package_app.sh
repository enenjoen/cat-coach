#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/../.." && pwd)"
OUTPUTS_DIR="$WORKSPACE_DIR/outputs"
APP_DIR="$OUTPUTS_DIR/小猫私教.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

cd "$PROJECT_DIR"
swift build -c release

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp ".build/release/PersonalTrainer" "$MACOS_DIR/PersonalTrainer"
cp "$SCRIPT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$SCRIPT_DIR/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
chmod +x "$MACOS_DIR/PersonalTrainer"

echo "已生成：$APP_DIR"
echo "你可以双击这个 .app 启动。"
