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
            leftMargin:   14
            rightMargin:  14
            topMargin:    4
            bottomMargin: 4
        }
        spacing: Theme.gap

        // ── 左: パワーメニュー ─────────────────────────────────────
        Rectangle {
            implicitHeight: Theme.pillH
            implicitWidth:  _pm.implicitWidth + 28
            radius:         Theme.radiusMd
            color:          _pmHov.hovered ? Theme.bgHover : Theme.bgLight
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            HoverHandler {
                id: _pmHov
                onHoveredChanged: _pm.expanded = hovered
            }

            PowerMenu {
                id:               _pm
                anchors.centerIn: parent
            }
        }

        Item { implicitWidth: 4 }

        // ── ワークスペース ─────────────────────────────────────────
        Rectangle {
            implicitHeight: Theme.pillH
            implicitWidth:  _ws.implicitWidth + 20
            radius:         Theme.radiusMd
            color:          Theme.bgLight

            Workspaces {
                id:              _ws
                anchors.centerIn: parent
                barScreen:       root.screen
            }
        }

        Item { implicitWidth: 4 }

        // ── 中央スペーサー ────────────────────────────────────────
        Item { Layout.fillWidth: true }

        // ── 右: ウィジェット群 ─────────────────────────────────────
        RowLayout {
            spacing: Theme.gap

            // Taildrop
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _tdrop.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                visible:        _tdrop.active

                Taildrop {
                    id:               _tdrop
                    anchors.centerIn: parent
                }
            }

            // CPU / メモリ
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _stats.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                SystemStats {
                    id:               _stats
                    anchors.centerIn: parent
                }
            }

            // 音量
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _vol.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                Volume {
                    id:              _vol
                    anchors.centerIn: parent
                }
            }

            // WiFi
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _net.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                Network {
                    id:              _net
                    anchors.centerIn: parent
                }
            }

            // Bluetooth
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _bt.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                Bluetooth {
                    id:              _bt
                    anchors.centerIn: parent
                }
            }

            // バッテリー（充電中のみ eww 同様に赤ボーダー）
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _bat.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                border.color:   Theme.red
                border.width:   BatteryService.acOnline ? 2 : 0
                Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

                Battery {
                    id:              _bat
                    anchors.centerIn: parent
                }
            }

            // IME（自己完結コンポーネント）
            Ime {}

            // スリープタイム
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _sleep.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                SleepTime {
                    id:              _sleep
                    anchors.centerIn: parent
                }
            }

            // 輝度
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _bri.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                Brightness {
                    id:              _bri
                    anchors.centerIn: parent
                }
            }

            // Recorder
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _rec.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight
                visible:        _rec.recording

                Recorder {
                    id:               _rec
                    anchors.centerIn: parent
                }
            }

            // GitHub Issues（スペーサー: 視覚は GithubIssues PanelWindow が担当）
            Item {
                id:             _ghSpacer
                implicitWidth:  GithubIssuesState.pillWidth
                implicitHeight: Theme.pillH

                function _sync() {
                    var p = mapToItem(null, width, 0)
                    GithubIssuesState.marginRight = root.screen.width - Theme.barMargin - p.x
                }
                onXChanged:     Qt.callLater(_sync)
                onWidthChanged: Qt.callLater(_sync)
            }

            // テンプレート（スペーサー: 視覚は TemplateWidget PanelWindow が担当）
            Item {
                id:             _tmplSpacer
                implicitWidth:  TemplateState.pillWidth
                implicitHeight: Theme.pillH

                function _sync() {
                    var p = mapToItem(null, width, 0)
                    TemplateState.marginRight = root.screen.width - Theme.barMargin - p.x
                }
                onXChanged:     Qt.callLater(_sync)
                onWidthChanged: Qt.callLater(_sync)
            }

            Connections {
                target:   CalendarState
                function onClockPillWidthChanged() {
                    Qt.callLater(_tmplSpacer._sync)
                    Qt.callLater(_ghSpacer._sync)
                }
            }

            Connections {
                target:   TemplateState
                function onPillWidthChanged() { Qt.callLater(_ghSpacer._sync) }
            }

            Connections {
                target:   GithubIssuesState
                function onPillWidthChanged() { Qt.callLater(_tmplSpacer._sync) }
            }

            // 日時
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _clk.implicitWidth + 28
                radius:         Theme.radiusMd
                color:          Theme.bgLight
                border.color:   Theme.cyan
                border.width:   CalendarState.open ? 1 : 0
                Behavior on border.width { NumberAnimation { duration: Theme.animFast } }
                Binding { target: CalendarState; property: "clockPillWidth"; value: implicitWidth }

                Clock {
                    id:               _clk
                    anchors.centerIn: parent
                }
            }
        }
    }
}
