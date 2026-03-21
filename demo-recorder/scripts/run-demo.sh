#!/usr/bin/env bash
# run-demo.sh - Hyprland Demo VM ランチャー (ホスト側)
#
# 使い方:
#   ./demo-recorder/scripts/run-demo.sh [demo.json]
#
# デフォルトのデモスクリプト: ./demo-recorder/demos/example.json
# 録画出力先: ~/vm-recordings/demo.mp4

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEMOS_DIR="$REPO_ROOT/demo-recorder/demos"
RECORDINGS_DIR="$HOME/vm-recordings"

DEMO_JSON="${1:-$DEMOS_DIR/example.json}"

if [ ! -f "$DEMO_JSON" ]; then
  echo "Error: demo script not found: $DEMO_JSON" >&2
  exit 1
fi

# demos/ にコピーして VM から /shared/demo.json で参照できるようにする
if [ "$(realpath "$DEMO_JSON")" != "$(realpath "$DEMOS_DIR/demo.json")" ]; then
  cp "$DEMO_JSON" "$DEMOS_DIR/demo.json"
fi

mkdir -p "$RECORDINGS_DIR"

echo "=== Hyprland Demo Recorder ==="
echo "  Demo script : $DEMO_JSON"
echo "  Output dir  : $RECORDINGS_DIR"
echo "  Building VM ..."

# demo-vm の nixos設定からQEMU起動スクリプトをビルド
VM_SCRIPT="$(nix build "$REPO_ROOT#nixosConfigurations.demo-vm.config.system.build.vm" \
  --no-link --print-out-paths 2>/dev/null)/bin/run-demo-vm-vm"

if [ ! -x "$VM_SCRIPT" ]; then
  echo "Error: VM build failed or script not found: $VM_SCRIPT" >&2
  exit 1
fi

echo "  Launching VM ..."
export HOME="$HOME"
export DEMO_DIR="$DEMOS_DIR"
export DEMO_SCRIPT="/shared/demo.json"

"$VM_SCRIPT"

echo ""
if [ -f "$RECORDINGS_DIR/demo.mp4" ]; then
  echo "Recording saved: $RECORDINGS_DIR/demo.mp4"
else
  echo "Warning: demo.mp4 not found in $RECORDINGS_DIR" >&2
  exit 1
fi
