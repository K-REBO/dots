import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Hyprland

// ── フローティングバー (eww 再現レイアウト) ───────────────────────
PanelWindow {
    id: root

    required property var screen

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.barMargin; right: Theme.barMargin }

    implicitHeight: Theme.barHeight
    color:          "transparent"
    exclusionMode:  ExclusionMode.Auto

    SystemClock { id: _sc; precision: SystemClock.Seconds }

    // ── バー背景 ──────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       Theme.radiusMd
        color:        "transparent"
        border.width: 0

        RowLayout {
            anchors {
                fill:         parent
                leftMargin:   10
                rightMargin:  10
                topMargin:    5
                bottomMargin: 5
            }
            spacing: Theme.gap

            // ── 左: NixOS アイコン ──────────────────────────────────
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _nixIcon.implicitWidth + 24
                radius:         Theme.radiusWs
                color:          Theme.bgPillCyan
                border.color:   Qt.rgba(0.00, 0.83, 1.00, 0.35)
                border.width:   1

                Text {
                    id:             _nixIcon
                    anchors.centerIn: parent
                    text:           "󱄅"
                    font.family:    Theme.fontFamily
                    font.pixelSize: 23
                    color:          Theme.cyan
                }
            }

            // セクション間スペース
            Item { implicitWidth: 14 }

            // ワークスペース pill
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _wsInner.implicitWidth + 16
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.border
                border.width:   1

                Workspaces {
                    id:           _wsInner
                    anchors.centerIn: parent
                    barScreen:    root.screen
                }
            }

            // セクション間スペース
            Item { implicitWidth: 6 }

            // ── 中央: スペーサー ──────────────────────────────────
            Item { Layout.fillWidth: true }

            // セクション間スペース
            Item { implicitWidth: 6 }

            // ── 右: ウィジェット群 ────────────────────────────────
            RowLayout {
                spacing: Theme.paddingMd

                // ── Taildrop ────────────────────────────────────────
                Taildrop {}

                // ── 音量 ─────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _volRow.implicitWidth + 20
                    radius:         Theme.radiusWs
                    color:          Theme.bgLight
                    border.color:   Theme.border
                    border.width:   1

                    RowLayout {
                        id:              _volRow
                        anchors.centerIn: parent
                        spacing:         5

                        Text {
                            text:            AudioService.icon
                            font.family:    Theme.iconFontFamily
                            font.pixelSize:  Theme.fontMd
                            color:           AudioService.muted ? Theme.fgDark : Theme.green
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                        Text {
                            text:  AudioService.volume + "%"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: AudioService.muted ? Theme.fgDark : Theme.green
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    AudioService.toggleMute()
                        onWheel: (w) => AudioService.changeVolume(w.angleDelta.y > 0 ? 5 : -5)
                    }
                }

                // ── WiFi ──────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _wifiRow.implicitWidth + 20
                    radius:         Theme.radiusWs
                    color:          Theme.bgLight
                    border.color:   Theme.border
                    border.width:   1

                    RowLayout {
                        id:              _wifiRow
                        anchors.centerIn: parent
                        spacing:         5

                        Text {
                            text:           NetworkService.icon
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontMd
                            color: NetworkService.ssid ? Theme.magenta : Theme.fgDark
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                        Text {
                            text:  NetworkService.ssid || "---"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: NetworkService.ssid ? Theme.magenta : Theme.fgDark
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            Layout.maximumWidth: 110
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }
                }

                // ── Bluetooth ────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _btRow.implicitWidth + 20
                    radius:         Theme.radiusWs
                    color:          Theme.bgLight
                    border.color:   Theme.border
                    border.width:   1

                    RowLayout {
                        id:              _btRow
                        anchors.centerIn: parent
                        spacing:         5

                        Text {
                            text:           BluetoothService.icon
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontMd
                            color: BluetoothService.connectedDevice ? Theme.blue : Theme.fgDark
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                        Text {
                            text:    BluetoothService.connectedDevice
                            visible: BluetoothService.connectedDevice !== ""
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color:   Theme.blue
                            elide:   Text.ElideRight
                            maximumLineCount: 1
                            Layout.maximumWidth: 90
                        }
                    }
                }

                // ── バッテリー ────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _batRow.implicitWidth + 20
                    radius:         Theme.radiusWs
                    color:          Theme.bgLight
                    border.color:   BatteryService.status === "Charging" ? Theme.red : Theme.border
                    border.width:   1
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                    RowLayout {
                        id:              _batRow
                        anchors.centerIn: parent
                        spacing:         5

                        Text {
                            text:           BatteryService.icon
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontMd
                            color: {
                                if (BatteryService.status === "Charging") return Theme.green
                                if (BatteryService.percent <= 20)         return Theme.red
                                return Theme.blue
                            }
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                        Text {
                            text:  BatteryService.percent + "%"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: {
                                if (BatteryService.status === "Charging") return Theme.green
                                if (BatteryService.percent <= 20)         return Theme.red
                                return Theme.blue
                            }
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                        Text {
                            // 計算できた場合のみ表示 ("0:00" は除外)
                            readonly property bool hasTime:
                                BatteryService.timeLeft !== "" && BatteryService.timeLeft !== "0:00"
                            text:    "(" + BatteryService.timeLeft + ")"
                            visible: hasTime
                            font { family: Theme.fontFamily; pixelSize: Theme.fontXs }
                            color:   Theme.fgDark
                        }
                    }
                }

                // ── IME ───────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _imeText.implicitWidth + 22
                    radius:         Theme.radiusWs
                    color:          Theme.bgLight
                    border.color:   Theme.border
                    border.width:   1

                    Text {
                        id:             _imeText
                        anchors.centerIn: parent
                        text:           ImeService.icon
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSm; bold: true }
                        color: ImeService.mode === "あ" ? Theme.yellow : Theme.fgSub
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    ImeService.toggle()
                    }
                }

                // ── 輝度 ──────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _briRow.implicitWidth + 20
                    radius:         Theme.radiusWs
                    color:          Theme.bgLight
                    border.color:   Theme.border
                    border.width:   1

                    RowLayout {
                        id:              _briRow
                        anchors.centerIn: parent
                        spacing:         5

                        Text {
                            text:           "󰃠"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontMd
                            color:          Theme.yellow
                        }
                        Text {
                            text:  BrightnessService.percent + "%"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: Theme.yellow
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onWheel: (w) => BrightnessService.change(w.angleDelta.y > 0 ? 5 : -5)
                    }
                }

                // ── レコーダー ────────────────────────────────────────
                Recorder {}

                // ── 日時 ──────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _dtRow.implicitWidth + 22
                    radius:         Theme.radiusWs
                    color:          Theme.bgPillBlue
                    border.color:   Qt.rgba(0.30, 0.60, 1.00, 0.30)
                    border.width:   1

                    RowLayout {
                        id:              _dtRow
                        anchors.centerIn: parent
                        spacing:         7

                        Text {
                            text:  Qt.formatDate(_sc.date, "MM/dd ddd").replace(".", "")
                            font { family: Theme.fontFamily; pixelSize: Theme.fontXs }
                            color: Theme.fgSub
                        }
                        Rectangle {
                            width: 1; height: 10
                            color: Qt.rgba(0.30, 0.60, 1.00, 0.35)
                        }
                        Text {
                            text:  Qt.formatTime(_sc.date, "HH:mm")
                            font { family: Theme.fontFamily; pixelSize: Theme.fontLg; bold: true }
                            color: Theme.fg
                        }
                    }
                }
            }
        }
    }
}
