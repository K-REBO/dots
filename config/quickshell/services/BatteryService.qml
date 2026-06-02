pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int    percent:  100
    property string status:   "Full"
    property string icon:     "󰁹"
    property string timeLeft: ""

    function updateIcon() {
        const dischargeIcons = ["󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]
        const chargeIcons    = ["󰢜","󰂆","󰂇","󰂈","󰢝","󰂉","󰢞","󰂊","󰂋","󰂅"]
        const idx = Math.min(9, Math.floor(percent / 10))
        icon = (status === "Charging") ? chargeIcons[idx] : dischargeIcons[idx]
    }

    property var _proc: Process {
        command: ["bash", "-c", `
            BAT=/sys/class/power_supply/BAT0
            [ -d "$BAT" ] || BAT=/sys/class/power_supply/BAT1
            if [ -d "$BAT" ]; then
                cap=$(cat "$BAT/capacity" 2>/dev/null || echo 100)
                stat=$(cat "$BAT/status" 2>/dev/null || echo Full)
                en=$(cat "$BAT/energy_now" 2>/dev/null || echo 0)
                pw=$(cat "$BAT/power_now" 2>/dev/null || echo 0)
                ef=$(cat "$BAT/energy_full" 2>/dev/null || echo 1)
                echo "$cap|$stat|$en|$pw|$ef"
            else
                echo "100|Full|0|0|1"
            fi
        `]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const p = line.split("|")
                root.percent = parseInt(p[0]) || 100
                root.status  = (p[1] || "Full").trim()
                const en = parseFloat(p[2]) || 0
                const pw = parseFloat(p[3]) || 0
                const ef = parseFloat(p[4]) || 1
                if (pw > 100) {
                    const hrs = root.status === "Charging" ? (ef - en) / pw : en / pw
                    const h = Math.floor(hrs)
                    const m = Math.floor((hrs - h) * 60)
                    root.timeLeft = h + ":" + String(m).padStart(2, "0")
                } else {
                    root.timeLeft = ""
                }
                root.updateIcon()
                root._proc.running = false
            }
        }
    }

    function refresh() { _proc.running = true }

    property var _timer: Timer {
        interval: 30000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
