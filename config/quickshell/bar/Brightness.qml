import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingXs

    property bool hovered: false

    HoverHandler { onHoveredChanged: root.hovered = hovered }

    // ── インライン スライダー ────────────────────────────────────
    Item {
        implicitWidth:  root.hovered ? 72 : 0
        implicitHeight: 20
        clip: true
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            x: 4; width: parent.width - 8; height: 4; radius: 2
            color: Theme.bgHover

            Rectangle {
                width:  (BrightnessService.percent / 100) * track.width
                height: 4; radius: 2; color: Theme.yellow
                Behavior on width { NumberAnimation { duration: 80 } }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                BrightnessService.setPercent(
                    Math.round((mouse.x - 4) / Math.max(1, width - 8) * 100))
            }
            onWheel: (wheel) => BrightnessService.change(wheel.angleDelta.y > 0 ? 5 : -5)
        }
    }

    Text {
        text:           "󰃠"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color:          Theme.yellow

        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => BrightnessService.change(wheel.angleDelta.y > 0 ? 5 : -5)
        }
    }

    Text {
        text:           BrightnessService.percent + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fgDark
    }
}
