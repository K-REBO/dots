import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

Item {
    id: root
    implicitWidth:  _drop.containsDrag ? 160
                  : (expanded           ? _icon.implicitWidth + _expandArea.implicitWidth + Theme.paddingXs
                  :                       _icon.implicitWidth + (FileDropState.count > 0 ? Theme.paddingXs + _badge.implicitWidth : 0))
    implicitHeight: Theme.pillH

    property bool expanded: false

    readonly property bool containsDrag: _drop.containsDrag

    Behavior on implicitWidth { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

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

    // ── 通常表示 ─────────────────────────────────────────────────
    RowLayout {
        anchors.centerIn: parent
        spacing:  Theme.paddingXs
        opacity:  _drop.containsDrag ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        // アイコン
        Text {
            id:             _icon
            text:           "󰉋"
            font.family:    Theme.iconFontFamily
            font.pixelSize: Theme.fontMd
            color:          FileDropState.count > 0 ? Theme.blue : Theme.fgSub
        }

        // hover展開ラベル
        Item {
            id:           _expandArea
            implicitWidth: root.expanded && !_drop.containsDrag
                           ? _label.implicitWidth : 0
            height:        Theme.pillH
            clip:          true
            Behavior on implicitWidth {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }

            Text {
                id:             _label
                anchors.verticalCenter: parent.verticalCenter
                text:           FileDropState.count > 0
                                ? FileDropState.count + " 件"
                                : "一時置き場"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSm
                color:          FileDropState.count > 0 ? Theme.blue : Theme.fgSub
            }
        }

        // バッジ（通常時・未展開）
        Rectangle {
            id:             _badge
            visible:        FileDropState.count > 0 && !root.expanded
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

    // ── ドロップゾーン表示 ────────────────────────────────────────
    RowLayout {
        anchors.centerIn: parent
        spacing:  Theme.paddingXs
        opacity:  _drop.containsDrag ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        Text {
            text:           "󰄼"
            font.family:    Theme.iconFontFamily
            font.pixelSize: Theme.fontMd
            color:          Theme.cyan
        }

        Text {
            text:           "ここにドロップ"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSm
            color:          Theme.cyan
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    FileDropState.toggle()
    }
}
