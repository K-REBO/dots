import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

PanelWindow {
    id: root
    required property var screen

    anchors { top: true; left: true }
    margins {
        top:  Theme.barMargin + Theme.barHeight
        left: SleepTimeState.marginLeft
    }

    implicitWidth:  SleepTimeState.pillWidth
    implicitHeight: _content.implicitHeight + 16
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore
    visible:        SleepTimeState.open

    mask: Region {
        x: 0; y: 0
        width:  _box.width
        height: _box.height
    }

    Rectangle {
        id:     _box
        width:  SleepTimeState.pillWidth
        height: _content.implicitHeight + 16
        radius: Theme.radiusMd
        color:  Theme.bgLight
        border.color: Theme.yellow
        border.width: 1

        HoverHandler {
            onHoveredChanged: SleepTimeState.open = hovered
        }

        ColumnLayout {
            id:                 _content
            anchors { top: parent.top; left: parent.left; right: parent.right }
            anchors.topMargin:   8
            anchors.leftMargin:  10
            anchors.rightMargin: 10
            spacing:             4

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
