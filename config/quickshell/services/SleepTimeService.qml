pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int    seconds: 300
    property string label:   "5分"

    function _updateLabel() {
        switch (seconds) {
            case 0:    label = "off";  break
            case 300:  label = "5m";   break
            case 900:  label = "15m";  break
            case 1800: label = "30m";  break
            case 3600: label = "1h"; break
            default:   label = Math.floor(seconds / 60) + "分"
        }
    }

    function set(secs) {
        seconds = secs
        _updateLabel()
        _setProc.command = [
            "bash", "-c",
            `~/.config/nix/config/eww/scripts/dpms-timeout set ${secs}`
        ]
        _setProc.running = true
    }

    property var _setProc: Process { running: false }

    property var _readProc: Process {
        command: ["bash", "-c",
            "cat \"$HOME/.local/share/hypridle/dpms-timeout\" 2>/dev/null || echo 300"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line.trim())
                if (!isNaN(v)) {
                    root.seconds = v
                    root._updateLabel()
                }
                root._readProc.running = false
            }
        }
    }

    function refresh() { _readProc.running = true }

    Component.onCompleted: refresh()
}
