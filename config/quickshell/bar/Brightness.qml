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
        implicitWidth:  root.hovered ? 90 : 0
        implicitHeight: Theme.pillH
        clip: true
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            x: 4; width: parent.width - 8; height: 6; radius: 3
            color: Theme.bgHover

            Rectangle {
                width:  Math.max(0, (BrightnessService.percent / 100) * track.width)
                height: 6; radius: 3
                color:  Theme.yellow
                Behavior on width { NumberAnimation { duration: 60 } }
            }

            Rectangle {
                x:       Math.max(0, (BrightnessService.percent / 100) * track.width) - 5
                y:       -3
                width:   10; height: 12; radius: 3
                color:   Theme.fg
                visible: sliderArea.containsMouse || sliderArea.pressed
            }
        }

        MouseArea {
            id: sliderArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.SizeHorCursor

            function apply(mx) {
                BrightnessService.setPercent(Math.round(
                    Math.max(0, Math.min(100, (mx - 4) / Math.max(1, width - 8) * 100))))
            }
            onPressed:         (m) => apply(m.x)
            onPositionChanged: (m) => { if (pressed) apply(m.x) }
            onWheel: (w) => BrightnessService.change(w.angleDelta.y > 0 ? 5 : -5)
        }
    }

    // ── アイコン ─────────────────────────────────────────────────
    Text {
        text:           "󰃠"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color:          Theme.yellow

        MouseArea {
            anchors.fill: parent
            onWheel: (w) => BrightnessService.change(w.angleDelta.y > 0 ? 5 : -5)
        }
    }

    // ── パーセント ───────────────────────────────────────────────
    Text {
        text:           BrightnessService.percent + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fgDark
    }
}
