import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingXs

    property bool hovered: false

    HoverHandler { onHoveredChanged: root.hovered = hovered }

    // ── インライン スライダー（ホバーで展開）──────────────────────
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
                width:  (AudioService.volume / 100) * track.width
                height: 4; radius: 2
                color:  AudioService.muted ? Theme.fgDim : Theme.blue
                Behavior on width { NumberAnimation { duration: 80 } }
                Behavior on color { ColorAnimation  { duration: Theme.animFast } }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                AudioService.setVolume(
                    Math.round((mouse.x - 4) / Math.max(1, width - 8) * 100))
            }
            onWheel: (wheel) => AudioService.changeVolume(wheel.angleDelta.y > 0 ? 5 : -5)
        }
    }

    // ── アイコン ─────────────────────────────────────────────────
    Text {
        text:           AudioService.icon
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color:          AudioService.muted ? Theme.fgDim : Theme.fg
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    AudioService.toggleMute()
            onWheel: (wheel) => AudioService.changeVolume(wheel.angleDelta.y > 0 ? 5 : -5)
        }
    }

    // ── パーセント ───────────────────────────────────────────────
    Text {
        text:           AudioService.volume + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          AudioService.muted ? Theme.fgDim : Theme.fgDark
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
}
