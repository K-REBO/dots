import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingSm

    property bool expanded: false

    HoverHandler {
        id: hov
        onHoveredChanged: root.expanded = hov.hovered
    }

    // スリープアイコン (eww dpms-icon と同じ)
    Text {
        text:           "󰒲"
        font.family:    Theme.iconFontFamily
        font.pixelSize: Theme.fontSm
        color:          hov.hovered ? Theme.yellow : Theme.fgDark
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    // 現在の設定ラベル
    Text {
        text:           SleepTimeService.label
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.yellow
    }

    // ホバーで展開するメニュー
    Item {
        id: expandArea
        enabled: expanded
        height: Theme.pillH
        implicitWidth:  expanded ? menuRow.implicitWidth + Theme.paddingSm : 0
        clip:           true
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        RowLayout {
            id: menuRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.paddingXs

            Rectangle { width: 1; height: 18; color: Theme.border }

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

                    implicitWidth:  btnText.implicitWidth + Theme.paddingMd
                    implicitHeight: 22
                    radius:         Theme.radiusSm
                    color: {
                        if (btnHov.hovered) return Qt.rgba(
                            Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.18)
                        if (isCurrent)      return Qt.rgba(
                            Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.12)
                        return "transparent"
                    }
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    border.color: isCurrent ? Qt.rgba(
                        Theme.yellow.r, Theme.yellow.g, Theme.yellow.b, 0.5) : "transparent"
                    border.width: 1

                    Text {
                        id:             btnText
                        anchors.centerIn: parent
                        text:           modelData.label
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        font.bold:      isCurrent
                        color:          isCurrent ? Theme.yellow : Theme.fgDark
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    HoverHandler { id: btnHov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    SleepTimeService.set(modelData.seconds)
                    }
                }
            }
        }
    }
}
