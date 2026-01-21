#!/bin/bash
# wf-recorderが既に実行中かチェック
if pgrep -x "wf-recorder" > /dev/null; then
    # 実行中の場合は停止シグナルを送信
    pkill --signal SIGINT wf-recorder
else
    # 実行中でない場合はフルスクリーン録画を開始
    # wf-recorderをバックグラウンドで実行
    wf-recorder &
fi
