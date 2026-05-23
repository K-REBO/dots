pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // "A" = 英数入力, "あ" = 日本語入力
    property string mode: "A"
    property string icon: "A"

    property var _proc: Process {
        command: ["fcitx5-remote"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const state = parseInt(line.trim())
                root.mode = (state === 2) ? "あ" : "A"
                root.icon = root.mode
                root._proc.running = false
            }
        }
    }

    function refresh() { _proc.running = true }

    function toggle() { _toggle.running = true }

    property var _toggle: Process {
        command: ["fcitx5-remote", "-t"]
        running: false
        onExited: root.refresh()
    }

    // D-Bus 監視でリアルタイム更新
    property var _monitor: Process {
        command: ["bash", "-c", `
            dbus-monitor --session \
                "type='signal',interface='org.fcitx.Fcitx5.Controller1'" 2>/dev/null
        `]
        running: true
        stdout: SplitParser { onRead: _ => root.refresh() }
    }

    property var _timer: Timer {
        interval: 2000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
