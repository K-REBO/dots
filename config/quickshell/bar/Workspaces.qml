import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Hyprland

// BarのscreenをpropertyとしてWorkspacesに渡す
Item {
    id: root

    property var barScreen: null

    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    // 対応モニターを特定する
    readonly property var monitor: {
        for (const m of Hyprland.monitors.values) {
            if (barScreen && m.name === barScreen.name) return m
        }
        return Hyprland.focusedMonitor
    }

    readonly property int activeWsId: monitor?.activeWorkspace?.id ?? -1

    // id順にソート（QMLのObjectModelはソート不要でIDで配列取得）
    readonly property var wsList: {
        const list = Hyprland.workspaces.values.slice()
        list.sort((a, b) => a.id - b.id)
        return list
    }

    readonly property int activeIndex: {
        for (let i = 0; i < wsList.length; i++)
            if (wsList[i].id === activeWsId) return i
        return -1
    }

    // ── スライドするハイライト ──────────────────────────────
    // 左端・右端を別々にアニメーションさせ、進行方向の端を先に動かして伸縮させる。
    // 案B(スワイプ追従)では _leftEdge/_rightEdge にスワイプ量を加算して上書きする。
    property real _leftEdge:  0
    property real _rightEdge: 0
    property bool _movingRight: true
    property bool _placed: false
    property color _hlColor: Theme.wsColor(Math.max(activeWsId, 1))

    // Hyprland側のworkspaceアニメーション(speed=4 ≒ 400ms)に揃える
    readonly property int _leadMs:  260
    readonly property int _trailMs: 420

    Behavior on _leftEdge {
        enabled: root._placed && !root._tracking
        NumberAnimation {
            duration:    root._movingRight ? root._trailMs : root._leadMs
            easing.type: Easing.OutCubic
        }
    }
    Behavior on _rightEdge {
        enabled: root._placed && !root._tracking
        NumberAnimation {
            duration:    root._movingRight ? root._leadMs : root._trailMs
            easing.type: Easing.OutCubic
        }
    }
    Behavior on _hlColor {
        enabled: !root._tracking
        ColorAnimation { duration: root._trailMs }
    }

    property int _prevIndex: -1

    // アクティブボタンの位置へハイライトを移動する
    function retarget() {
        if (_tracking) return
        const btn = _rep.itemAt(activeIndex)
        if (!btn || btn.width <= 0) return

        if (_prevIndex >= 0 && activeIndex !== _prevIndex)
            _movingRight = activeIndex > _prevIndex
        _prevIndex = activeIndex

        const x = _row.x + btn.x
        _leftEdge  = x
        _rightEdge = x + btn.width
        _hlColor   = Theme.wsColor(activeWsId)

        // 初回配置はアニメーションさせない
        if (!_placed) Qt.callLater(() => { root._placed = true })
    }

    // ── スワイプ追従 (案B) ─────────────────────────────────
    // スワイプ中は指の移動量に比例してハイライトを動かす(アニメーション無効)。
    // 確定/取り消しはHyprlandの判断に任せ、指を離した後にactiveIndexの結果へアニメーションで収束させる。
    property bool _tracking: false

    // スワイプに追従するのはフォーカス中のモニターのバーだけ
    readonly property bool _isFocusedBar: monitor !== null && monitor === Hyprland.focusedMonitor

    // 進行度: +1で次のワークスペース、-1で前のワークスペース
    readonly property real swipeProgress: {
        const p = Theme.wsSwipeDirection * _swipe.dx / Theme.wsSwipeDistance
        return Math.max(-1, Math.min(1, p))
    }

    function _mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t, 1)
    }

    function applySwipe() {
        const cur = _rep.itemAt(activeIndex)
        if (!cur) return
        const p = swipeProgress
        const t = Math.abs(p)
        const nb = _rep.itemAt(activeIndex + (p > 0 ? 1 : -1))

        const cl = _row.x + cur.x
        const cr = cl + cur.width
        if (nb) {
            const nl = _row.x + nb.x
            const nr = nl + nb.width
            _leftEdge  = cl + (nl - cl) * t
            _rightEdge = cr + (nr - cr) * t
            _hlColor   = _mix(Theme.wsColor(activeWsId), Theme.wsColor(nb.workspace.id), t)
        } else {
            // 端: これ以上進めないので少しだけ引っ張って止める(ゴム紐)
            const pull = Math.sign(p) * t * 10
            _leftEdge  = cl + pull
            _rightEdge = cr + pull
        }
    }

    SwipeTracker {
        id: _swipe
        onBegan: {
            if (!root._isFocusedBar) return
            root._tracking = true
        }
        onEnded: {
            if (!root._tracking) return
            root._tracking = false
            // Hyprlandの切り替え確定を待ってから収束させる。
            // 取り消し(切り替わらない)場合はここで元の位置へ戻る
            _settle.restart()
        }
        onDxChanged: if (root._tracking) root.applySwipe()
    }

    Timer {
        id: _settle
        interval: 150
        onTriggered: root.retarget()
    }

    onActiveIndexChanged: Qt.callLater(retarget)
    onActiveWsIdChanged:  Qt.callLater(retarget)

    Rectangle {
        id: _highlight
        visible: root.activeIndex >= 0 && root._rightEdge > root._leftEdge
        x:       root._leftEdge
        y:       _row.y + (_row.height - height) / 2
        width:   root._rightEdge - root._leftEdge
        height:  Theme.pillH - 6
        radius:  Theme.radiusSm
        color:   root._hlColor
        border.color: Qt.darker(root._hlColor, 1.1)
        border.width: 1
    }

    RowLayout {
        id: _row
        spacing: Theme.paddingXs

        Repeater {
            id: _rep
            model: root.wsList

            delegate: WorkspaceButton {
                required property var modelData
                workspace: modelData
                isActive:  modelData.id === root.activeWsId

                // ハイライトが覆っている割合(行座標に直して重なり幅を求める)
                cover: {
                    const l = root._leftEdge - _row.x
                    const r = root._rightEdge - _row.x
                    const ov = Math.min(r, x + width) - Math.max(l, x)
                    return width > 0 ? Math.max(0, Math.min(1, ov / width)) : 0
                }

                // アイコン数の変化などで幅が変わったら追従する
                onXChanged:     if (isActive) Qt.callLater(root.retarget)
                onWidthChanged: if (isActive) Qt.callLater(root.retarget)
            }

            onItemAdded:   Qt.callLater(root.retarget)
            onItemRemoved: Qt.callLater(root.retarget)
        }
    }
}
