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
    // キューエントリ: { cmd: [...], callback: function|null }

    property var _queue:           []
    property var _currentCallback: null

    property Process _proc: Process {
        onRunningChanged: {
            if (!running) {
                if (root._currentCallback) {
                    root._currentCallback()
                    root._currentCallback = null
                }
                if (root._queue.length > 0) {
                    const entry = root._queue.shift()
                    root._currentCallback = entry.callback
                    command = entry.cmd
                    running = true
                }
            }
        }
    }

    function _enqueue(cmd, callback) {
        const entry = { cmd: cmd, callback: callback || null }
        if (_proc.running) {
            _queue.push(entry)
        } else {
            _currentCallback = entry.callback
            _proc.command = entry.cmd
            _proc.running = true
        }
    }

    Component.onCompleted: {
        _scanProc.command = ["bash", "-c",
            "mkdir -p /tmp/drag-drop/storage /tmp/drag-drop/trash && " +
            "find /tmp/drag-drop/storage -mindepth 2 -maxdepth 2 -type f -printf '%P\\n' 2>/dev/null"]
        _scanProc.running = true
    }

    // ── 起動時 storage スキャン ───────────────────────────────────

    property Process _scanProc: Process {
        stdout: SplitParser {
            onRead: line => {
                const rel = line.trim()           // "20260603_142530_456/foo.txt"
                if (!rel || !rel.includes("/")) return
                const name = rel.split("/").pop() // "foo.txt"
                const path = "/tmp/drag-drop/storage/" + rel
                const idx  = root.files.count
                // 起動時スキャン: ファイルはすでに存在するので ready: true
                root.files.append({ name: name, path: path, preview: "", ready: true })
                if (!root._isImageFile(name)) root._enqueuePreview(idx, path)
            }
        }
    }

    // ── ファイル追加・削除 ────────────────────────────────────────

    function addFile(srcPath) {
        const name  = srcPath.replace(/^.*\//, "")
        const dir   = "/tmp/drag-drop/storage/" + _generatePrefix()
        const dest  = dir + "/" + name
        const isImg = _isImageFile(name)
        const idx   = files.count
        // cp 完了前に追加（ready: false）→ cp 完了後に ready: true + preview 開始
        files.append({ name: name, path: dest, preview: "", ready: false })
        _enqueue(["bash", "-c",
            "mkdir -p -- " + JSON.stringify(dir) + " && cp -- " +
            JSON.stringify(srcPath) + " " + JSON.stringify(dest)],
            function() {
                if (idx < root.files.count) {
                    root.files.setProperty(idx, "ready", true)
                    if (!isImg) root._enqueuePreview(idx, dest)
                }
            })
    }

    function trashFile(idx) {
        if (idx < 0 || idx >= files.count) return
        const item    = files.get(idx)
        const parts   = item.path.split("/")
        const dirName = parts[parts.length - 2]
        _enqueue(["mv", "--",
            "/tmp/drag-drop/storage/" + dirName,
            "/tmp/drag-drop/trash/" + dirName])
        files.remove(idx)
        selectedIndices = selectedIndices
            .filter(i => i !== idx)
            .map(i => i > idx ? i - 1 : i)
    }

    function removeSelected() {
        const sorted = selectedIndices.slice().sort((a, b) => b - a)
        for (const i of sorted) {
            if (i >= 0 && i < files.count) {
                const item    = files.get(i)
                const parts   = item.path.split("/")
                const dirName = parts[parts.length - 2]
                _enqueue(["mv", "--",
                    "/tmp/drag-drop/storage/" + dirName,
                    "/tmp/drag-drop/trash/" + dirName])
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
        _readProc.command = ["bash", "-c",
            "file --mime-type -b -- " + JSON.stringify(item.path) +
            " | grep -q '^text/' && head -c 500 -- " + JSON.stringify(item.path) + " || true"]
        _readProc.running = true
    }

    function _enqueuePreview(idx, path) {
        _previewQueue.push({ idx: idx, path: path })
        if (!_readProc.running) _processPreviewQueue()
    }

    // ── ユーティリティ ────────────────────────────────────────────

    function _generatePrefix() {
        const d  = new Date()
        const p2 = n => String(n).padStart(2, '0')
        const p3 = n => String(n).padStart(3, '0')
        return d.getFullYear() + p2(d.getMonth()+1) + p2(d.getDate()) +
               '_' + p2(d.getHours()) + p2(d.getMinutes()) + p2(d.getSeconds()) +
               '_' + p3(d.getMilliseconds())
    }

    function _isImageFile(name) {
        const ext = (name.split(".").pop() || "").toLowerCase()
        return ["png","jpg","jpeg","gif","webp","bmp","svg"].indexOf(ext) >= 0
    }
}
