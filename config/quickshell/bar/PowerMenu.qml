import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Io

RowLayout {
    id: root
    spacing: Theme.paddingSm

    property bool expanded: false

    // NixOS ロゴ
    Text {
        text:           "󱄅"
        font.family:    Theme.fontFamily
        font.pixelSize: 18
        color:          Theme.cyan
    }

    // 展開エリア（折りたたみ中はイベントを受け取らない）
    Item {
        id: expandArea
        enabled:      root.expanded
        height:       Theme.pillH
        implicitWidth: root.expanded ? menuRow.implicitWidth + Theme.paddingSm : 0
        clip:         true
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
                    { icon: "",   label: "Shutdown", cmd: "systemctl poweroff",       col: Theme.red     },
                    { icon: "",   label: "Reboot",   cmd: "systemctl reboot",          col: Theme.yellow  },
                    { icon: "󰒲", label: "Sleep",    cmd: "systemctl suspend",         col: Theme.green   },
                    { icon: "",   label: "Lock",     cmd: "qs ipc call lock activate", col: Theme.blue    },
                    { icon: "󰍃", label: "Logout",   cmd: "hyprctl dispatch exit",     col: Theme.magenta },
                ]

                delegate: Rectangle {
                    required property var modelData
                    implicitWidth:  btnContent.implicitWidth + Theme.paddingMd
                    implicitHeight: 26
                    radius:         Theme.radiusSm
                    color:          btnHov.hovered
                                    ? Qt.rgba(modelData.col.r, modelData.col.g, modelData.col.b, 0.18)
                                    : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    RowLayout {
                        id: btnContent
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text:           modelData.icon
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontMd
                            color:          modelData.col
                        }
                        Text {
                            text:           modelData.label
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            color:          modelData.col
                        }
                    }

                    HoverHandler { id: btnHov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            const proc = Qt.createQmlObject(
                                'import Quickshell.Io; Process { command: ["bash","-c","' +
                                modelData.cmd.replace(/"/g, '\\"') + '"]; running: true }',
                                root)
                        }
                    }
                }
            }
        }
    }
}
