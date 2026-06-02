pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int  volume: 50
    property bool muted:  false
    property string icon: "󰕾"

    function updateIcon() {
        if (muted)          icon = "󰖁"
        else if (volume >= 70) icon = "󰕾"
        else if (volume >= 30) icon = "󰖀"
        else                   icon = "󰕿"
    }

    // ── One-shot volume fetch ────────────────────────────────────
    property var _fetch: Process {
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 2) {
                    root.volume = Math.round(parseFloat(parts[1]) * 100)
                    root.muted  = line.includes("[MUTED]")
                    root.updateIcon()
                }
                root._fetch.running = false
            }
        }
    }

    function refresh() { _fetch.running = true }

    // ── Monitor via pactl subscribe ──────────────────────────────
    property var _sub: Process {
        command: ["bash", "-c", "pactl subscribe 2>/dev/null | grep --line-buffered 'sink'"]
        running: true
        stdout: SplitParser { onRead: _ => root.refresh() }
    }

    // ── Fallback timer ───────────────────────────────────────────
    property var _timer: Timer {
        interval: 5000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    // ── Control ──────────────────────────────────────────────────
    function setVolume(pct) {
        _setVol.command = ["bash", "-c",
            "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.max(0, Math.min(100, pct)) + "%"]
        _setVol.running = true
    }

    function changeVolume(delta) { setVolume(volume + delta) }

    function toggleMute() { _mute.running = true }

    property var _setVol: Process {
        running: false; onExited: root.refresh()
    }
    property var _mute: Process {
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        running: false; onExited: root.refresh()
    }

    Component.onCompleted: refresh()
}
