import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

PanelWindow {
    id: root

    required property var screen

    anchors { top: true; right: true }
    margins {
        top:   Theme.barHeight + Theme.barMargin * 3
        right: Theme.barMargin
    }

    implicitWidth:  320
    implicitHeight: calCol.implicitHeight + 28
    color:          "transparent"
    visible:        CalendarState.open
    exclusionMode:  ExclusionMode.Ignore

    SystemClock { id: _clk; precision: SystemClock.Seconds }

    // 表示月の状態（カレンダーナビ用）
    property int viewYear:  _clk.date.getFullYear()
    property int viewMonth: _clk.date.getMonth()  // 0-indexed

    // カレンダーを開くたびに今月にリセット
    onVisibleChanged: if (visible) {
        viewYear  = _clk.date.getFullYear()
        viewMonth = _clk.date.getMonth()
    }

    // ── ポップアップ背景 ─────────────────────────────────────────
    Rectangle {
        anchors { fill: parent; margins: 6 }
        radius:       Theme.radiusMd
        color:        Qt.rgba(0.06, 0.06, 0.14, 0.96)
        border.color: Theme.border
        border.width: 1

        // 外側クリックで閉じる
        MouseArea {
            anchors.fill: parent
            onClicked:    CalendarState.close()
            propagateComposedEvents: true
        }

        ColumnLayout {
            id:       calCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing:  10

            // ── 大きい時刻表示 ──────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text:             Qt.formatTime(_clk.date, "HH:mm")
                font.family:      Theme.fontFamily
                font.pixelSize:   48
                font.bold:        true
                color:            Theme.fg
            }

            // ── 日付（フル） ────────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text:             Qt.formatDate(_clk.date, "dddd, MMMM d")
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSm
                color:            Theme.fgSub
            }

            // ── 区切り線 ────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color:  Theme.border
            }

            // ── 月ナビゲーション ────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text:           "<"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                    color:          Theme.fgDark
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            if (root.viewMonth === 0) {
                                root.viewMonth = 11
                                root.viewYear--
                            } else {
                                root.viewMonth--
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(
                        new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSm
                    font.bold:      true
                    color:          Theme.fg
                }

                Text {
                    text:           ">"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                    color:          Theme.fgDark
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            if (root.viewMonth === 11) {
                                root.viewMonth = 0
                                root.viewYear++
                            } else {
                                root.viewMonth++
                            }
                        }
                    }
                }
            }

            // ── 曜日ヘッダー ────────────────────────────────────
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 0
                rowSpacing: 2

                Repeater {
                    model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text:           modelData
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontXs
                        color:          (index === 0 || index === 6)
                                        ? Theme.fgDim : Theme.fgSub
                    }
                }

                // ── 日付グリッド（42セル固定）──────────────────
                Repeater {
                    id: _days

                    readonly property int _firstDow: new Date(root.viewYear, root.viewMonth, 1).getDay()
                    readonly property int _daysInMonth: new Date(root.viewYear, root.viewMonth + 1, 0).getDate()
                    readonly property int _today:      _clk.date.getDate()
                    readonly property int _todayMonth: _clk.date.getMonth()
                    readonly property int _todayYear:  _clk.date.getFullYear()

                    model: 42

                    delegate: Item {
                        Layout.fillWidth: true
                        implicitHeight:   22

                        readonly property int dayNum: index - _days._firstDow + 1
                        readonly property bool inMonth:
                            dayNum >= 1 && dayNum <= _days._daysInMonth
                        readonly property bool isToday:
                            inMonth
                            && dayNum         === _days._today
                            && root.viewMonth === _days._todayMonth
                            && root.viewYear  === _days._todayYear

                        Rectangle {
                            anchors.centerIn: parent
                            width:  22; height: 22
                            radius: 11
                            color:  isToday ? Theme.cyan : "transparent"
                            visible: inMonth
                        }

                        Text {
                            anchors.centerIn: parent
                            text:           inMonth ? dayNum : ""
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontXs
                            font.bold:      isToday
                            color:          isToday ? "#000000"
                                          : (inMonth ? Theme.fg : "transparent")
                        }
                    }
                }
            }

            Item { implicitHeight: 4 }
        }
    }
}
