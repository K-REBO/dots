#!/usr/bin/env bash
TMP=$(mktemp /tmp/ocr-XXXXXX.png)
grimblast save area "$TMP" && \
  python3 -c "
from manga_ocr import MangaOcr
mocr = MangaOcr()
print(mocr('$TMP'))
" | tr -d '\n' | wl-copy && \
  notify-send "OCR" "クリップボードにコピーしました" --expire-time=3000
rm -f "$TMP"
