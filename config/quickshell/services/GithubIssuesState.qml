pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool open:        false
    property real pillWidth:   0
    property real marginRight: 0
    property bool loading:     false
    property var  issues:      []

    readonly property string _cachePath: "$HOME/.cache/quickshell/github_issues.json"

    // createdAtRaw（ISO日時）から相対表記の createdAt を都度算出する
    function _formatIssue(i) {
        const days = Math.floor((Date.now() - new Date(i.createdAtRaw).getTime()) / 86400000)
        const age  = days <= 0 ? "今日" : days === 1 ? "昨日" : days + "日前"
        return {
            number:       i.number,
            title:        i.title,
            url:          i.url,
            repo:         i.repo,
            createdAt:    age,
            createdAtRaw: i.createdAtRaw
        }
    }

    property var _proc: Process {
        command: [
            "bash", "-c",
            `gh search issues --owner @me --state open --created ">$(date -d '7 days ago' +%Y-%m-%d)" --limit 5 --json title,url,number,repository,createdAt 2>/dev/null | awk '{printf "%s", $0} END{print ""}' || echo "[]"`
        ]
        running: false
        stdout: SplitParser {
            onRead: line => {
                if (!line.trim()) return
                try {
                    const raw = JSON.parse(line)
                    const formatted = raw.map(i => root._formatIssue({
                        number:       i.number,
                        title:        i.title,
                        url:          i.url,
                        repo:         i.repository ? (i.repository.nameWithOwner || "") : "",
                        createdAtRaw: i.createdAt
                    }))
                    root.issues = formatted
                    root._writeCache(formatted)
                } catch(e) {
                    // 取得失敗時はキャッシュ済みのスナップショットを表示し続ける
                }
                root.loading = false
                root._proc.running = false
            }
        }
    }

    function refresh() {
        if (loading) return
        loading = true
        _proc.running = true
    }

    property var _timer: Timer {
        interval: 600000
        repeat:   true
        running:  true
        onTriggered: root.refresh()
    }

    // ── キャッシュ ────────────────────────────────────────────────
    // 起動直後（refresh完了前）でも直近のスナップショットを表示するため、
    // ディスクに保存した結果を読み込んでおく。

    property Process _cacheReadProc: Process {
        command: ["bash", "-c", `cat "${root._cachePath}" 2>/dev/null`]
        running: false
        stdout: SplitParser {
            onRead: line => {
                if (!line.trim()) return
                try {
                    const raw = JSON.parse(line)
                    root.issues = raw.map(i => root._formatIssue(i))
                } catch(e) {}
            }
        }
    }

    property Process _cacheWriteProc: Process { running: false }

    function _writeCache(data) {
        const json = JSON.stringify(data)
        _cacheWriteProc.command = ["bash", "-c",
            `mkdir -p "$HOME/.cache/quickshell" && cat > "${root._cachePath}" <<'GHISSUES_EOF'\n${json}\nGHISSUES_EOF\n`]
        _cacheWriteProc.running = true
    }

    Component.onCompleted: {
        _cacheReadProc.running = true
        refresh()
    }
}
