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
                    root.issues = raw.map(i => {
                        const days = Math.floor((Date.now() - new Date(i.createdAt).getTime()) / 86400000)
                        const age  = days === 0 ? "今日" : days === 1 ? "昨日" : days + "日前"
                        return {
                            number:    i.number,
                            title:     i.title,
                            url:       i.url,
                            repo:      i.repository ? (i.repository.nameWithOwner || "") : "",
                            createdAt: age
                        }
                    })
                } catch(e) {
                    root.issues = []
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

    Component.onCompleted: refresh()
}
