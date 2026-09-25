import QtQuick
import Quickshell.Io

// タッチパッドの多指スワイプを libinput debug-events から読み取る。
// Hyprlandはスワイプ中の進行量をIPC/Luaイベントで公開しないため、
// libinputを直接読んでバー側の追従アニメーションに使う。
// (Hyprland自身のジェスチャー処理とは独立。確定/取り消しはHyprland側の結果に従う)
Item {
    id: root

    property int fingers: 3

    // スワイプ中か
    readonly property bool swiping: _swiping
    // BEGINからの水平方向の累積移動量(unaccelerated)。左が負
    readonly property real dx: _dx

    signal began()
    signal ended()

    property bool _swiping: false
    property real _dx: 0

    Process {
        id: _proc
        running: true
        // パイプ接続だと行バッファされず遅延するためstdbufで行バッファにする
        command: ["stdbuf", "-oL", "libinput", "debug-events"]
        stdout: SplitParser {
            onRead: data => root._handle(data)
        }
        onExited: _restart.start()
    }

    Timer {
        id: _restart
        interval: 3000
        onTriggered: _proc.running = true
    }

    // 例: " event11  GESTURE_SWIPE_UPDATE   2  +0.294s\t3 -0.88/ 0.29 (-0.88/ 0.29 unaccelerated)"
    // 正の値は "( 0.00/-0.29" のように括弧の後ろにスペースが入る点に注意
    readonly property var _re:
        /GESTURE_SWIPE_(BEGIN|UPDATE|END)\s+(?:\d+\s+)?\+[\d.]+s\s+(\d+)(?:\s+-?[\d.]+\/\s*-?[\d.]+\s+\(\s*(-?[\d.]+)\/\s*(-?[\d.]+)\s+unaccelerated)?/

    function _handle(line) {
        if (line.indexOf("GESTURE_SWIPE_") < 0) return
        const m = _re.exec(line)
        if (!m || parseInt(m[2]) !== fingers) return

        switch (m[1]) {
        case "BEGIN":
            _dx = 0
            _swiping = true
            began()
            break
        case "UPDATE":
            if (_swiping && m[3] !== undefined) _dx += parseFloat(m[3])
            break
        case "END":
            if (_swiping) {
                _swiping = false
                ended()
            }
            break
        }
    }
}
