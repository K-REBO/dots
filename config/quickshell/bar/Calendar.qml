import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

// バーの直下に配置（バーと重ならないため Hyprland がバー幅を再計算しない）
// 幅・高さ同時アニメーションで Clock pill からの拡張に見せる
PanelWindow {
    id: root

    required property var screen

    anchors { top: true; right: true }
    margins {
        top:   Theme.barHeight + Theme.barMargin
        right: Theme.barMargin
    }

    // キャンバスは最大サイズ固定、_widget が実際の表示領域を制御
    implicitWidth:  320
    implicitHeight: _calCol.implicitHeight + 28
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    mask: Region {
        x:      _widget.x
        y:      0
        width:  _widget.width
        height: _widget.height
    }

    SystemClock { id: _clk; precision: SystemClock.Seconds }

    property int viewYear:  _clk.date.getFullYear()
    property int viewMonth: _clk.date.getMonth()

    Connections {
        target: CalendarState
        function onOpenChanged() {
            if (CalendarState.open) {
                root.viewYear  = _clk.date.getFullYear()
                root.viewMonth = _clk.date.getMonth()
            }
        }
    }

    // ── 幅・高さ同時アニメーション ──────────────────────────────────
    property real _panelH: CalendarState.open
                           ? implicitHeight
                           : 0
    Behavior on _panelH {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    property real _panelW: CalendarState.open
                           ? 320
                           : CalendarState.clockPillWidth
    Behavior on _panelW {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    // ── ウィジェット本体（右端に寄せる）────────────────────────────
    Rectangle {
        id: _widget

        anchors { top: parent.top; right: parent.right }
        width:  root._panelW
        height: root._panelH

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgPanel
        border.color: Theme.cyan
        border.width: CalendarState.open ? 1 : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        ColumnLayout {
            id:       _calCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing:  10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text:             Qt.formatTime(_clk.date, "HH:mm")
                font.family:      Theme.fontFamily
                font.pixelSize:   48
                font.bold:        true
                color:            Theme.fg
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text:             Qt.formatDate(_clk.date, "dddd, MMMM d")
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSm
                color:            Theme.fgSub
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "<"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontMd; color: Theme.fgDark
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (root.viewMonth === 0) { root.viewMonth = 11; root.viewYear-- } else root.viewMonth-- }
                    }
                }
                Text {
                    Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontSm; font.bold: true; color: Theme.fg
                }
                Text {
                    text: ">"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontMd; color: Theme.fgDark
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (root.viewMonth === 11) { root.viewMonth = 0; root.viewYear++ } else root.viewMonth++ }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true; columns: 7; columnSpacing: 0; rowSpacing: 2

                Repeater {
                    model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                    Text {
                        Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                        text: modelData; font.family: Theme.fontFamily; font.pixelSize: Theme.fontXs
                        color: (index === 0 || index === 6) ? Theme.fgDim : Theme.fgSub
                    }
                }

                Repeater {
                    id: _days
                    readonly property int _firstDow:    new Date(root.viewYear, root.viewMonth, 1).getDay()
                    readonly property int _daysInMonth: new Date(root.viewYear, root.viewMonth + 1, 0).getDate()
                    readonly property int _today: _clk.date.getDate()
                    model: 42

                    delegate: Item {
                        Layout.fillWidth: true; implicitHeight: 22
                        readonly property int  dayNum:  index - _days._firstDow + 1
                        readonly property bool inMonth: dayNum >= 1 && dayNum <= _days._daysInMonth
                        readonly property bool isToday:
                            inMonth && dayNum === _days._today
                            && root.viewMonth === _clk.date.getMonth() && root.viewYear === _clk.date.getFullYear()

                        Rectangle {
                            anchors.centerIn: parent; width: 22; height: 22; radius: 11
                            color: isToday ? Theme.cyan : "transparent"; visible: inMonth
                        }
                        Text {
                            anchors.centerIn: parent
                            text: inMonth ? dayNum : ""; font.family: Theme.fontFamily; font.pixelSize: Theme.fontXs
                            font.bold: isToday; color: isToday ? "#000000" : (inMonth ? Theme.fg : "transparent")
                        }
                    }
                }
            }

            Item { implicitHeight: 4 }
        }
    }
}
