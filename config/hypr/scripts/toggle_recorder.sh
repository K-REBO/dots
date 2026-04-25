#!/usr/bin/env bash
# 録画保存先
SAVE_DIR="$HOME/downloads"
mkdir -p "$SAVE_DIR"

if pgrep -x "wf-recorder" > /dev/null; then
    # 停止
    pkill --signal SIGINT wf-recorder
else
    # 開始（タイムスタンプ付きファイル名）
    FILENAME="$SAVE_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"
    wf-recorder --audio=alsa_output.pci-0000_04_00.6.HiFi__Speaker__sink.monitor -f "$FILENAME" &
fi
