import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

// ── フローティングバー ─────────────────────────────────────────────
PanelWindow {
    id: root

    required property var screen

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.barMargin; right: Theme.barMargin }

    implicitHeight: Theme.barHeight
    color:          "transparent"
    exclusionMode:  ExclusionMode.Auto

    RowLayout {
        anchors {
            fill:         parent
            leftMargin:   10
            rightMargin:  10
            topMargin:    5
            bottomMargin: 5
        }
        spacing: Theme.gap

        // ── 左: パワーメニュー ─────────────────────────────────────
        Rectangle {
            implicitHeight: parent.height
            implicitWidth:  _pwr.implicitWidth + 24
            radius:         Theme.radiusWs
            color:          Theme.bgPillCyan
            border.color:   Qt.rgba(0.00, 0.83, 1.00, 0.35)
            border.width:   1

            PowerMenu {
                id:              _pwr
                anchors.centerIn: parent
            }
        }

        Item { implicitWidth: 8 }

        // ── ワークスペース ─────────────────────────────────────────
        Rectangle {
            implicitHeight: parent.height
            implicitWidth:  _ws.implicitWidth + 16
            radius:         Theme.radiusWs
            color:          Theme.bgLight
            border.color:   Theme.border
            border.width:   1

            Workspaces {
                id:              _ws
                anchors.centerIn: parent
                barScreen:       root.screen
            }
        }

        Item { implicitWidth: 4 }

        // ── 中央スペーサー ─────────────────────────────────────────
        Item { Layout.fillWidth: true }

        Item { implicitWidth: 4 }

        // ── 右: ウィジェット群 ─────────────────────────────────────
        RowLayout {
            spacing: Theme.gap

            // Taildrop（自己完結コンポーネント）
            Taildrop {}

            // 音量
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _vol.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.border
                border.width:   1

                Volume {
                    id:              _vol
                    anchors.centerIn: parent
                }
            }

            // WiFi
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _net.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.border
                border.width:   1

                Network {
                    id:              _net
                    anchors.centerIn: parent
                }
            }

            // Bluetooth
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _bt.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.border
                border.width:   1

                Bluetooth {
                    id:              _bt
                    anchors.centerIn: parent
                }
            }

            // バッテリー
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _bat.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   BatteryService.status === "Charging"
                                ? Theme.green : Theme.border
                border.width:   1
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Battery {
                    id:              _bat
                    anchors.centerIn: parent
                }
            }

            // IME（自己完結コンポーネント）
            Ime {}

            // スリープタイム
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _sleep.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.border
                border.width:   1

                SleepTime {
                    id:              _sleep
                    anchors.centerIn: parent
                }
            }

            // 輝度
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _bri.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.border
                border.width:   1

                Brightness {
                    id:              _bri
                    anchors.centerIn: parent
                }
            }

            // Recorder（自己完結コンポーネント）
            Recorder {}

            // 日時（青アクセントピル）
            Rectangle {
                implicitHeight: parent.height
                implicitWidth:  _clk.implicitWidth + 22
                radius:         Theme.radiusWs
                color:          Theme.bgPillBlue
                border.color:   CalendarState.open
                                ? Qt.rgba(0.00, 0.83, 1.00, 0.50)
                                : Qt.rgba(0.30, 0.60, 1.00, 0.30)
                border.width:   1
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Clock {
                    id:              _clk
                    anchors.centerIn: parent
                }
            }
        }
    }
}
