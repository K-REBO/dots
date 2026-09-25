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
        enabled: root._placed
        NumberAnimation {
            duration:    root._movingRight ? root._trailMs : root._leadMs
            easing.type: Easing.OutCubic
        }
    }
    Behavior on _rightEdge {
        enabled: root._placed
        NumberAnimation {
            duration:    root._movingRight ? root._leadMs : root._trailMs
            easing.type: Easing.OutCubic
        }
    }
    Behavior on _hlColor { ColorAnimation { duration: root._trailMs } }

    property int _prevIndex: -1

    // アクティブボタンの位置へハイライトを移動する
    function retarget() {
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

                // アイコン数の変化などで幅が変わったら追従する
                onXChanged:     if (isActive) Qt.callLater(root.retarget)
                onWidthChanged: if (isActive) Qt.callLater(root.retarget)
            }

            onItemAdded:   Qt.callLater(root.retarget)
            onItemRemoved: Qt.callLater(root.retarget)
        }
    }
}
