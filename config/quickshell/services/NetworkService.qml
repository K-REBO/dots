pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string ssid:    ""
    property int    signal:  0
    property string ip:      ""
    property string gateway: ""
    property string icon:    "󰤭"

    function updateIcon() {
        if (!ssid || ssid === "--") { icon = "󰤭"; return }
        if (signal >= 75)  icon = "󰤨"
        else if (signal >= 50) icon = "󰤥"
        else if (signal >= 25) icon = "󰤢"
        else                   icon = "󰤟"
    }

    property var _proc: Process {
        command: ["bash", "-c", `
            info=$(nmcli -t -f SSID,SIGNAL,ACTIVE device wifi 2>/dev/null | grep ':yes$' | head -1)
            name=$(echo "$info" | cut -d: -f1)
            sig=$(echo "$info"  | cut -d: -f2)
            ip=$(ip -4 addr show | awk '/inet / && !/127\.0\.0\.1/{print $2}' | cut -d/ -f1 | head -1)
            gw=$(ip route show default 2>/dev/null | awk 'NR==1{print $3}')
            printf '%s|%s|%s|%s\n' "$name" "\${sig:-0}" "$ip" "$gw"
        `]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const p    = line.split("|")
                root.ssid    = p[0] || ""
                root.signal  = parseInt(p[1]) || 0
                root.ip      = p[2] || ""
                root.gateway = p[3] || ""
                root.updateIcon()
                root._proc.running = false
            }
        }
    }

    function refresh() { _proc.running = true }

    property var _monitor: Process {
        command: ["bash", "-c", "nmcli monitor 2>/dev/null"]
        running: true
        stdout: SplitParser { onRead: _ => root.refresh() }
    }

    property var _timer: Timer {
        interval: 15000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
