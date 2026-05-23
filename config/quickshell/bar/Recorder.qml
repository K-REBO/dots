import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Io

RowLayout {
    id: root
    spacing: Theme.paddingSm
    visible: recording

    property bool   recording: false
    property string elapsed:   ""

    property var _proc: Process {
        command: ["bash", "-c", `
            while true; do
                pid=$(pgrep -x wf-recorder | head -1)
                if [ -n "$pid" ]; then
                    s=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')
                    m=$(( \${s:-0} / 60 ))
                    sec=$(( \${s:-0} % 60 ))
                    printf '1|%02d:%02d\n' "$m" "$sec"
                else
                    echo '0|'
                fi
                sleep 1
            done
        `]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const p = line.split("|")
                root.recording = (p[0] === "1")
                root.elapsed   = p[1] || ""
            }
        }
    }

    // 点滅するドット
    Rectangle {
        width: 8; height: 8; radius: 4
        color: Theme.red

        SequentialAnimation on opacity {
            running: root.recording; loops: Animation.Infinite
            NumberAnimation { to: 0.2; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
        }
    }

    Text {
        text:           root.elapsed
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.red
    }
}
