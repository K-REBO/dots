import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

Item {
    id: root
    implicitWidth:  _row.implicitWidth
    implicitHeight: Theme.pillH

    property bool expanded: false
    readonly property bool containsDrag: _drop.containsDrag

    DropArea {
        id: _drop
        anchors.fill: parent

        onDropped: drop => {
            const urls = drop.urls
            for (let i = 0; i < urls.length; i++) {
                const url = urls[i].toString()
                if (url.startsWith("file://")) {
                    FileDropState.addFile(decodeURIComponent(url.slice(7)))
                }
            }
            drop.accept(Qt.CopyAction)
        }
    }

    RowLayout {
        id: _row
        anchors.centerIn: parent
        spacing: Theme.paddingXs

        // ── アイコン（常時表示）───────────────────────────────────
        Text {
            text:           "󰈔"
            font.family:    Theme.iconFontFamily
            font.pixelSize: Theme.fontMd
            color:          _drop.containsDrag ? Theme.cyan
                          : FileDropState.count > 0 ? Theme.blue
                          : Theme.fgSub
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }

        // ── 展開エリア（hover / drag で slide-in）────────────────
        Item {
            id: _expandArea
            enabled:      root.expanded || _drop.containsDrag
            height:       Theme.pillH
            implicitWidth: (root.expanded || _drop.containsDrag)
                           ? _content.implicitWidth + Theme.paddingXs : 0
            clip: true
            Behavior on implicitWidth {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }

            RowLayout {
                id: _content
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingXs

                Rectangle { width: 1; height: 16; color: Theme.border }

                Text {
                    text:           _drop.containsDrag        ? "ここにドロップ"
                                  : FileDropState.count > 0  ? FileDropState.count + " 件"
                                  :                            "一時置き場"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSm
                    color:          _drop.containsDrag        ? Theme.cyan
                                  : FileDropState.count > 0  ? Theme.blue
                                  :                            Theme.fgSub
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
        }

        // ── バッジ（未展開・非ドラッグ時のみ）──────────────────
        Rectangle {
            visible:        FileDropState.count > 0
                            && !root.expanded
                            && !_drop.containsDrag
            implicitWidth:  _num.implicitWidth + 8
            implicitHeight: 18
            radius:         Theme.radiusFull
            color:          Theme.blue

            Text {
                id:             _num
                anchors.centerIn: parent
                text:           FileDropState.count
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontXs - 2
                color:          "#07070e"
                font.bold:      true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
    }
}
