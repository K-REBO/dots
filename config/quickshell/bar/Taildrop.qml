import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Io

RowLayout {
    id: root
    spacing: Theme.paddingSm
    visible: active

    property bool   active:   false
    property string filename: ""
    property string status:   ""
    property string size:     ""

    property var _proc: Process {
        command: ["bash", "-c", `
            journalctl --user -u taildrop.service -f -n 0 2>/dev/null | \
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
                    printf '1|%s|受信完了|%s\n' "$name" "$sz"
                fi
            done
        `]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const p    = line.split("|")
                root.active   = (p[0] === "1")
                root.filename = p[1] || ""
                root.status   = p[2] || ""
                root.size     = p[3] || ""
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 6000
        onTriggered: root.active = false
    }

    Text {
        text:           "󰛶"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color:          Theme.cyan
    }

    Column {
        spacing: 1

        Text {
            text:           root.filename
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSm - 1
            color:          Theme.fg
            width:          90
            elide:          Text.ElideRight
        }

        Text {
            text:           root.status + (root.size ? " " + root.size : "")
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSm - 2
            color:          Theme.fgDark
        }
    }
}
