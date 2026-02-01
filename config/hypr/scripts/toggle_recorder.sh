#!/bin/bash
# 録画保存先
SAVE_DIR="$HOME/downloads"
mkdir -p "$SAVE_DIR"

if pgrep -x "wf-recorder" > /dev/null; then
    # 停止
    pkill --signal SIGINT wf-recorder
    notify-send "録画停止" "保存先: $SAVE_DIR"
else
    # 開始（タイムスタンプ付きファイル名）
    FILENAME="$SAVE_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"
    notify-send "録画開始" "Shift+PrtSc で停止"
    wf-recorder -f "$FILENAME" &
fi
