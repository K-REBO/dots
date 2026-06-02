pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int  volume: 50
    property bool muted:  false
    property string icon: "󰕾"

    property bool micMuted: false

    function updateIcon() {
        if (muted)             icon = "󰖁"
        else if (volume >= 70) icon = "󰕾"
        else if (volume >= 30) icon = "󰖀"
        else                   icon = "󰕿"
    }

    // ── スピーカー音量取得 ────────────────────────────────────────
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

    // ── マイクミュート状態取得 ────────────────────────────────────
    property var _micFetch: Process {
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                root.micMuted = line.includes("[MUTED]")
                root._micFetch.running = false
                // ThinkPad マイクミュート LED 同期
                root._ledSync.running = true
            }
        }
    }

    function refreshMic() { _micFetch.running = true }

    property var _ledSync: Process {
        command: ["bash", "-c",
            "(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo 1 || echo 0) > /sys/class/leds/platform::micmute/brightness 2>/dev/null || true"]
        running: false
    }

    // ── pactl subscribe でスピーカー／マイク変化を監視 ───────────
    property var _sub: Process {
        command: ["bash", "-c", "pactl subscribe 2>/dev/null | grep --line-buffered 'sink\\|source'"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("sink"))   root.refresh()
                if (line.includes("source")) root.refreshMic()
            }
        }
    }

    property var _timer: Timer {
        interval: 5000; repeat: true; running: true
        onTriggered: { root.refresh(); root.refreshMic() }
    }

    // ── スピーカー制御 ───────────────────────────────────────────
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

    Component.onCompleted: { refresh(); refreshMic() }
}
