import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

// ── SleepTime ウィジェット（pill + dropdown 一体型）──────────────────
//
// GithubIssues と同構造: PanelWindow は最大サイズ固定、内側の _widget だけ
// アニメーション。mask で入力領域を _widget に限定することでカクつきを防ぐ。
PanelWindow {
    id: root
    required property var screen

    anchors { top: true; left: true }
    margins {
        top:  Theme.barMargin + (Theme.barHeight - Theme.pillH) / 2
        left: SleepTimeState.marginLeft
    }

    implicitWidth:  _widget.implicitWidth
    implicitHeight: Theme.pillH + 200   // 固定最大値: OS ウィンドウをリサイズしない
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    mask: Region {
        x: 0; y: 0
        width:  _widget.implicitWidth
        height: _widget.height          // アニメーション中の実寸に追従
    }

    Binding { target: SleepTimeState; property: "pillWidth"; value: _widget.implicitWidth }

    // ── ウィジェット本体 ──────────────────────────────────────────
    Rectangle {
        id: _widget
        anchors { top: parent.top; left: parent.left }

        implicitWidth: _pillRow.implicitWidth + 20
        height: SleepTimeState.open
                ? (Theme.pillH + 1 + _dropContent.implicitHeight + 16)
                : Theme.pillH
        Behavior on height {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgLight
        border.color: Theme.yellow
        border.width: SleepTimeState.open ? 1 : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        HoverHandler {
            onHoveredChanged: SleepTimeState.open = hovered
        }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // ── ピル行 ────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight:   Theme.pillH

                RowLayout {
                    id:      _pillRow
                    anchors.centerIn: parent
                    spacing: Theme.paddingSm

                    Text {
                        text:           "󰒲"
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontSm
                        color:          SleepTimeState.open ? Theme.yellow : Theme.fgDark
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    Text {
                        text:           SleepTimeService.label
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.yellow
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
                opacity:          SleepTimeState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            // ── ドロップダウンコンテンツ ──────────────────────────
            ColumnLayout {
                id:                 _dropContent
                Layout.fillWidth:   true
                Layout.topMargin:   8
                Layout.leftMargin:  10
                Layout.rightMargin: 10
                spacing:            4
                opacity:            SleepTimeState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                Repeater {
                    model: [
                        { label: "5分",   seconds: 300  },
                        { label: "15分",  seconds: 900  },
                        { label: "30分",  seconds: 1800 },
                        { label: "1時間", seconds: 3600 },
                        { label: "無効",  seconds: 0    },
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        readonly property bool isCurrent:
                            SleepTimeService.seconds === modelData.seconds

                        Layout.fillWidth: true
                        implicitHeight:   28
                        radius:           Theme.radiusSm
                        color: {
                            if (_hov.hovered) return Qt.rgba(
                                Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.18)
                            if (isCurrent)    return Qt.rgba(
                                Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.12)
                            return "transparent"
                        }
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        border.color: isCurrent
                            ? Qt.rgba(Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.5)
                            : "transparent"
                        border.width: 1

                        HoverHandler { id: _hov }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                SleepTimeService.set(modelData.seconds)
                                SleepTimeState.open = false
                            }
                        }

                        Text {
                            anchors.centerIn:   parent
                            text:               modelData.label
                            font.family:        Theme.fontFamily
                            font.pixelSize:     Theme.fontSm
                            font.bold:          isCurrent
                            color:              isCurrent ? Theme.yellow : Theme.fgDark
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }
}
