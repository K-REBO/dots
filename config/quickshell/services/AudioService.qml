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
                if (line.includes("sink"))   { root.refresh(); root.refreshStreams() }
                if (line.includes("source")) root.refreshMic()
            }
        }
    }

    property var _timer: Timer {
        interval: 5000; repeat: true; running: true
        onTriggered: { root.refresh(); root.refreshMic(); root.refreshStreams() }
    }

    // ── アプリ別音量（wpctl status の Streams: セクション）────────
    // streams: [{ id, name, volume(0-100), muted }]
    // wpctl status にはstream単体の音量が出ないため、一覧をawkで抽出した後
    // 各IDに get-volume を個別に叩いて音量を結合する。
    property var streams:    []
    property var _streamsTmp: []
    property string _streamsSig: ""

    property var _streamsFetch: Process {
        running: false
        command: ["bash", "-c", `
wpctl status | awk '
  /^Audio$/    { grp = "audio";  next }
  /^Video$/    { grp = "video"; instream = 0; next }
  /^Settings$/ { grp = "settings"; instream = 0; next }
  grp == "audio" && /Streams:/ { instream = 1; next }
  grp == "audio" && /(Sinks|Sources|Filters):/ { instream = 0 }
  instream && /^[[:space:]]+[0-9]+\\./ && $0 !~ />/ {
    line = $0
    sub(/^[[:space:]]+/, "", line)
    split(line, a, ".")
    id = a[1]
    name = line
    sub(/^[0-9]+\\.[[:space:]]*/, "", name)
    sub(/[[:space:]]+$/, "", name)
    print id "|" name
  }
' | while IFS='|' read -r id name; do
    vol=$(wpctl get-volume "$id" 2>/dev/null)
    [ -z "$vol" ] && continue
    pct=$(echo "$vol" | grep -oE '[0-9.]+' | head -1)
    muted=$(echo "$vol" | grep -c MUTED)
    printf '%s|%s|%s|%s\\n' "$id" "$name" "$pct" "$muted"
  done
`]
        onRunningChanged: if (running) root._streamsTmp = []
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split("|")
                if (parts.length >= 4) {
                    root._streamsTmp.push({
                        id:     parseInt(parts[0]),
                        name:   parts[1],
                        volume: Math.round(parseFloat(parts[2]) * 100),
                        muted:  parts[3] === "1"
                    })
                }
            }
        }
        onExited: {
            // 中身が変わっていない限り streams への再代入を避ける。
            // var プロパティは参照が変わるだけで binding が再評価され、
            // Repeater 全体が作り直されて dropdown の高さアニメーションが
            // 毎ポーリング(5秒ごと)再トリガーされ、hover 中にガクつく原因になっていた。
            const sig = JSON.stringify(root._streamsTmp)
            if (sig !== root._streamsSig) {
                root._streamsSig = sig
                root.streams = root._streamsTmp
            }
        }
    }

    function refreshStreams() { _streamsFetch.running = true }

    function setStreamVolume(id, pct) {
        _setStreamVol.command = ["bash", "-c",
            "wpctl set-volume " + id + " " + Math.max(0, Math.min(100, pct)) + "%"]
        _setStreamVol.running = true
    }
    property var _setStreamVol: Process { running: false; onExited: root.refreshStreams() }

    function toggleStreamMute(id) {
        _toggleStreamMute.command = ["wpctl", "set-mute", "" + id, "toggle"]
        _toggleStreamMute.running = true
    }
    property var _toggleStreamMute: Process { running: false; onExited: root.refreshStreams() }

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

    Component.onCompleted: { refresh(); refreshMic(); refreshStreams() }
}
