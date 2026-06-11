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
            implicitWidth:  _pm.implicitWidth + 20
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
            id:      _rightRL
            spacing: Theme.gap

            // innerRL の幅が変わるとグローバル位置が変わるため全 spacer を再 sync
            onWidthChanged: {
                Qt.callLater(_batSpacer._sync)
                Qt.callLater(_sleepSpacer._sync)
                Qt.callLater(_ghSpacer._sync)
                Qt.callLater(_notifSpacer._sync)
            }

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

            // RunCat (CPU負荷で走るNyanCat)
            Rectangle {
                implicitHeight: Theme.pillH
                implicitWidth:  _runcat.implicitWidth + 20
                radius:         Theme.radiusWs
                color:          Theme.bgLight

                // CPU使用率に応じた枠線（50%以上で黄色、80%以上で赤）
                border.width: SystemStatsService.cpuPercent >= 50 ? 2 : 0
                border.color: SystemStatsService.cpuPercent >= 80 ? Theme.red : Theme.yellow
                Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }
                Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

                RunCat {
                    id:               _runcat
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

            // バッテリー（スペーサー: 視覚は Battery PanelWindow が担当）
            Item {
                id:             _batSpacer
                implicitWidth:  BatteryState.pillWidth
                implicitHeight: Theme.pillH

                function _sync() {
                    var p = mapToItem(null, 0, 0)
                    BatteryState.marginLeft = Theme.barMargin + p.x
                }
                onXChanged:            Qt.callLater(_sync)
                onWidthChanged:        Qt.callLater(_sync)
                Component.onCompleted: Qt.callLater(_sync)
            }

            // IME（自己完結コンポーネント）
            Ime {}

            // スリープタイム（スペーサー: 視覚は SleepTime PanelWindow が担当）
            Item {
                id:             _sleepSpacer
                implicitWidth:  SleepTimeState.pillWidth
                implicitHeight: Theme.pillH

                function _sync() {
                    var p = mapToItem(null, 0, 0)
                    SleepTimeState.marginLeft = Theme.barMargin + p.x
                }
                onXChanged:            Qt.callLater(_sync)
                onWidthChanged:        Qt.callLater(_sync)
                Component.onCompleted: Qt.callLater(_sync)
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

            Connections {
                target:   CalendarState
                function onClockPillWidthChanged() { Qt.callLater(_ghSpacer._sync) }
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

            // 通知ベル（スペーサー: 視覚は Notifications PanelWindow が担当、最右）
            Item {
                id:             _notifSpacer
                implicitWidth:  NotificationState.pillWidth
                implicitHeight: Theme.pillH

                function _sync() {
                    var p = mapToItem(null, width, 0)
                    NotificationState.marginRight = root.screen.width - Theme.barMargin - p.x
                }
                onXChanged:     Qt.callLater(_sync)
                onWidthChanged: Qt.callLater(_sync)
            }
        }
    }
}
