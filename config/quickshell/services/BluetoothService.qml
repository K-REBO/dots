pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool   powered:         false
    property string connectedDevice: ""
    property string icon:            "󰂲"

    function updateIcon() {
        if (!powered)              icon = "󰂲"
        else if (connectedDevice)  icon = "󰂱"
        else                       icon = "󰂯"
    }

    property var _proc: Process {
        command: ["bash", "-c", `
            power=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')
            name=$(bluetoothctl info 2>/dev/null | awk '/Name:/{$1=""; print substr($0,2); exit}')
            printf '%s|%s\n' "$power" "$name"
        `]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const p = line.split("|")
                root.powered         = (p[0] || "").trim() === "yes"
                root.connectedDevice = (p[1] || "").trim()
                root.updateIcon()
                root._proc.running = false
            }
        }
    }

    function refresh() { _proc.running = true }

    function toggle() { _toggle.running = true }

    property var _toggle: Process {
        command: ["bash", "-c",
            "bluetoothctl show | grep -q 'Powered: yes' " +
            "&& bluetoothctl power off || bluetoothctl power on"]
        running: false
        onExited: root.refresh()
    }

    property var _monitor: Process {
        command: ["bash", "-c", "bluetoothctl --timeout 999999 monitor 2>/dev/null"]
        running: true
        stdout: SplitParser { onRead: _ => root.refresh() }
    }

    property var _timer: Timer {
        interval: 8000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
