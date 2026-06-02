import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Io

RowLayout {
    id: root
    spacing: Theme.paddingXs

    property bool   active:   false
    property string filename: ""
    property string size:     ""

    property var _proc: Process {
        command: ["bash", "-c", `
            stdbuf -oL journalctl --user -u taildrop.service -f -n 0 2>/dev/null | \
            while IFS= read -r line; do
                if echo "$line" | grep -q 'wrote '; then
                    name=$(echo "$line" | sed "s/.*wrote \\([^ ]*\\) as.*/\\1/")
                    bytes=$(echo "$line" | sed "s/.*(\\([0-9]*\\) bytes).*/\\1/")
                    sz=""
                    if [ -n "$bytes" ] && [ "$bytes" -gt 0 ] 2>/dev/null; then
                        if   [ "$bytes" -ge 1073741824 ]; then sz=$(awk "BEGIN{printf \"%.1fGB\",$bytes/1073741824}")
                        elif [ "$bytes" -ge 1048576 ];    then sz=$(awk "BEGIN{printf \"%.1fMB\",$bytes/1048576}")
                        elif [ "$bytes" -ge 1024 ];       then sz=$(awk "BEGIN{printf \"%.1fKB\",$bytes/1024}")
                        else sz="\${bytes}B"; fi
                    fi
                    printf '1|%s|%s\n' "$name" "$sz"
                fi
            done
        `]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const p     = line.split("|")
                root.active   = (p[0] === "1")
                root.filename = p[1] || ""
                root.size     = p[2] || ""
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 6000
        onTriggered: root.active = false
    }

    // アイコン
    Text {
        text:           "󰛶"
        font.family:    Theme.iconFontFamily
        font.pixelSize: Theme.fontMd
        color:          Theme.cyan
    }

    // ファイル名（省略あり）
    Text {
        text:           root.filename
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fg
        width:          80
        elide:          Text.ElideRight
    }

    // サイズ
    Text {
        text:           root.size
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fgDark
        visible:        root.size !== ""
    }
}
