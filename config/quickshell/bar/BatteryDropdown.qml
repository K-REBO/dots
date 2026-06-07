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
        left: BatteryState.marginLeft
    }

    implicitWidth:  BatteryState.pillWidth
    implicitHeight: _content.implicitHeight + 16
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore
    visible:        BatteryState.open

    mask: Region {
        x: 0; y: 0
        width:  _box.width
        height: _box.height
    }

    Rectangle {
        id:     _box
        width:  BatteryState.pillWidth
        height: _content.implicitHeight + 16
        radius: Theme.radiusMd
        color:  Theme.bgLight
        border.color: BatteryService.acOnline ? Theme.red : Theme.blue
        border.width: 1

        HoverHandler {
            onHoveredChanged: BatteryState.open = hovered
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
                    { icon: "󱐋", label: "Perf", profile: "performance", accent: Theme.orange },
                    { icon: "󰾆", label: "Bal",  profile: "balanced",    accent: Theme.yellow },
                    { icon: "󰌱", label: "Low",  profile: "low-power",   accent: Theme.green  },
                ]

                delegate: Rectangle {
                    required property var modelData

                    readonly property bool  isCurrent: TlpService.currentProfile === modelData.profile
                    readonly property color accent:    modelData.accent

                    Layout.fillWidth: true
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
