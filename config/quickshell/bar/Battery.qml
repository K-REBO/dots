import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

// ── Battery ウィジェット（pill + dropdown 一体型）─────────────────────
//
// GithubIssues と同構造: PanelWindow は最大サイズ固定、内側の _widget だけ
// アニメーション。mask で入力領域を _widget に限定することでカクつきを防ぐ。
PanelWindow {
    id: root
    required property var screen

    anchors { top: true; left: true }
    margins {
        top:  Theme.barMargin + (Theme.barHeight - Theme.pillH) / 2
        left: BatteryState.marginLeft
    }

    implicitWidth:  _widget.implicitWidth
    implicitHeight: Theme.pillH + 150   // 固定最大値: OS ウィンドウをリサイズしない
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    mask: Region {
        x: 0; y: 0
        width:  _widget.implicitWidth
        height: _widget.height          // アニメーション中の実寸に追従
    }

    Binding { target: BatteryState; property: "pillWidth"; value: _widget.implicitWidth }

    // ── ウィジェット本体 ──────────────────────────────────────────
    Rectangle {
        id: _widget
        anchors { top: parent.top; left: parent.left }

        // pillRow（時刻表示の有無で幅が変わる）と dropdown 内容、
        // 広い方に合わせることで dropdown の崩れを防ぐ
        implicitWidth: Math.max(_pillRow.implicitWidth, _dropContent.implicitWidth) + 20
        height: BatteryState.open
                ? (Theme.pillH + 1 + _dropContent.implicitHeight + 16)
                : Theme.pillH
        Behavior on height {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgLight
        border.color: BatteryService.acOnline ? Theme.red : Theme.blue
        border.width: (BatteryService.acOnline || BatteryState.open)
                      ? (BatteryService.acOnline ? 2 : 1) : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        HoverHandler {
            onHoveredChanged: BatteryState.open = hovered
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
                        text: {
                            switch (TlpService.currentProfile) {
                                case "performance": return "󱐋"
                                case "balanced":    return "󰾆"
                                case "low-power":   return "󰌱"
                                default:            return "󰾆"
                            }
                        }
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color: {
                            switch (TlpService.currentProfile) {
                                case "performance": return Theme.orange
                                case "balanced":    return Theme.yellow
                                case "low-power":   return Theme.green
                                default:            return Theme.fgDim
                            }
                        }
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    Text {
                        text:           BatteryService.icon
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontMd
                        color: {
                            if (BatteryService.status === "Charging") return Theme.green
                            if (BatteryService.percent <= 15)         return Theme.red
                            if (BatteryService.percent <= 35)         return Theme.yellow
                            return Theme.blue
                        }
                        Behavior on color { ColorAnimation { duration: 500 } }
                    }

                    Text {
                        text:           BatteryService.percent + "%"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color: {
                            if (BatteryService.status === "Charging") return Theme.green
                            if (BatteryService.percent <= 15)         return Theme.red
                            if (BatteryService.percent <= 35)         return Theme.yellow
                            return Theme.blue
                        }
                        Behavior on color { ColorAnimation { duration: 500 } }
                    }

                    Text {
                        visible:        BatteryService.timeLeft !== ""
                        text:           BatteryService.timeLeft
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm - 1
                        color:          Theme.purple
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
                opacity:          BatteryState.open ? 1 : 0
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
                opacity:            BatteryState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                Repeater {
                    model: [
                        { icon: "󱐋", label: "Perf", profile: "performance", accent: Theme.orange },
                        { icon: "󰾆", label: "Bal",  profile: "balanced",    accent: Theme.yellow },
                        { icon: "󰌱", label: "Low",  profile: "low-power",   accent: Theme.green  },
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        readonly property bool  isCurrent: TlpService.currentProfile === modelData.profile
                        readonly property color accent:    modelData.accent

                        Layout.fillWidth: true
                        implicitWidth:    _rowContent.implicitWidth + 20
                        implicitHeight:   28
                        radius:           Theme.radiusSm
                        color: {
                            if (_hov.hovered) return Qt.rgba(accent.r, accent.g, accent.b, 0.18)
                            if (isCurrent)    return Qt.rgba(accent.r, accent.g, accent.b, 0.12)
                            return "transparent"
                        }
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        border.color: isCurrent
                            ? Qt.rgba(accent.r, accent.g, accent.b, 0.5)
                            : "transparent"
                        border.width: 1

                        HoverHandler { id: _hov }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                TlpService.setProfile(modelData.profile)
                                BatteryState.open = false
                            }
                        }

                        RowLayout {
                            id: _rowContent
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                            spacing: 6

                            Text {
                                text:           modelData.icon
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                color:          isCurrent ? accent : Theme.fgDark
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }
                            Text {
                                text:             modelData.label
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontSm
                                font.bold:        isCurrent
                                color:            isCurrent ? accent : Theme.fgDark
                                Layout.fillWidth: true
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }
}
