pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int percent: 100

    property var _fetch: Process {
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                root.percent = parseInt(line.trim()) || 100
                root._fetch.running = false
            }
        }
    }

    function refresh() { _fetch.running = true }

    function setPercent(val) {
        _set.command = ["bash", "-c",
            "brightnessctl s " + Math.max(1, Math.min(100, Math.round(val))) + "%"]
        _set.running = true
    }

    function change(delta) {
        const sign = delta >= 0 ? "+" : ""
        _change.command = ["bash", "-c",
            "brightnessctl s " + sign + Math.abs(delta) + "%"]
        _change.running = true
    }

    property var _set:    Process { running: false; onExited: root.refresh() }
    property var _change: Process { running: false; onExited: root.refresh() }

    // inotify 監視 → フォールバックタイマー
    property var _watch: Process {
        command: ["bash", "-c", `
            path=$(ls /sys/class/backlight/*/brightness 2>/dev/null | head -1)
            if [ -n "$path" ]; then
                inotifywait -m -e close_write "$path" 2>/dev/null
            fi
        `]
        running: true
        stdout: SplitParser { onRead: _ => root.refresh() }
    }

    property var _timer: Timer {
        interval: 3000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
