pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool hovered: false
    property var selectedIndices: []
    property ListModel files: ListModel {}
    readonly property int count: files.count

    function startHover() { _closeTimer.stop(); hovered = true }
    function endHover()   { _closeTimer.restart() }

    property Timer _closeTimer: Timer {
        interval: 200
        onTriggered: root.hovered = false
    }

    function clearSelection() { selectedIndices = [] }

    function toggleSelect(idx) {
        let arr = selectedIndices.slice()
        const pos = arr.indexOf(idx)
        if (pos >= 0) arr.splice(pos, 1)
        else arr.push(idx)
        selectedIndices = arr
    }

    function isSelected(idx) {
        return selectedIndices.indexOf(idx) >= 0
    }

    // ── ファイル操作キュー ────────────────────────────────────────

    property var _queue: []

    property Process _proc: Process {
        onRunningChanged: {
            if (!running && root._queue.length > 0) {
                command = root._queue.shift()
                running = true
            }
        }
    }

    function _enqueue(cmd) {
        if (_proc.running) {
            _queue.push(cmd)
        } else {
            _proc.command = cmd
            _proc.running = true
        }
    }

    Component.onCompleted: {
        _enqueue(["bash", "-c", "mkdir -p /tmp/drag-drop/storage /tmp/drag-drop/trash"])
    }

    function addFile(srcPath) {
        const name = srcPath.replace(/^.*\//, "")
        const dest = "/tmp/drag-drop/storage/" + name
        _enqueue(["cp", "--", srcPath, dest])
        const idx = files.count
        files.append({ name: name, path: dest, preview: "" })
        if (!_isImageFile(name)) _enqueuePreview(idx, srcPath)
    }

    function trashFile(idx) {
        if (idx < 0 || idx >= files.count) return
        const item = files.get(idx)
        _enqueue(["mv", "--", item.path, "/tmp/drag-drop/trash/" + item.name])
        files.remove(idx)
        selectedIndices = selectedIndices
            .filter(i => i !== idx)
            .map(i => i > idx ? i - 1 : i)
    }

    function removeSelected() {
        const sorted = selectedIndices.slice().sort((a, b) => b - a)
        for (const i of sorted) {
            if (i >= 0 && i < files.count) {
                const item = files.get(i)
                _enqueue(["mv", "--", item.path, "/tmp/drag-drop/trash/" + item.name])
                files.remove(i)
            }
        }
        clearSelection()
    }

    // ── テキストプレビュー読み取り ────────────────────────────────

    property var    _previewQueue: []
    property string _readBuf:      ""
    property int    _readIdx:      -1

    property Process _readProc: Process {
        stdout: SplitParser {
            onRead: line => root._readBuf += (root._readBuf ? "\n" : "") + line
        }
        onRunningChanged: {
            if (!running) {
                if (root._readIdx >= 0 && root._readIdx < files.count)
                    files.setProperty(root._readIdx, "preview", root._readBuf)
                root._readBuf = ""
                root._readIdx = -1
                root._processPreviewQueue()
            }
        }
    }

    function _processPreviewQueue() {
        if (_previewQueue.length === 0) return
        const item = _previewQueue.shift()
        _readIdx  = item.idx
        _readBuf  = ""
        // MIME が text/* の場合のみ先頭 500 bytes を出力、それ以外は無出力
        _readProc.command = ["bash", "-c",
            "file --mime-type -b -- " + JSON.stringify(item.path) +
            " | grep -q '^text/' && head -c 500 -- " + JSON.stringify(item.path) + " || true"]
        _readProc.running = true
    }

    function _enqueuePreview(idx, path) {
        _previewQueue.push({ idx: idx, path: path })
        if (!_readProc.running) _processPreviewQueue()
    }

    function _isImageFile(name) {
        const ext = (name.split(".").pop() || "").toLowerCase()
        return ["png","jpg","jpeg","gif","webp","bmp","svg"].indexOf(ext) >= 0
    }
}
