import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingXs

    property bool hovered: false

    HoverHandler { onHoveredChanged: root.hovered = hovered }

    Text {
        text:           NetworkService.icon
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color:          "#e76fec"
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Text {
        text:           NetworkService.ssid || "──"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          "#e76fec"
        Layout.maximumWidth: 90
        elide:          Text.ElideRight
    }

    // ── ホバーで詳細表示 ─────────────────────────────────────────
    Item {
        implicitHeight: detailRow.implicitHeight
        implicitWidth:  root.hovered ? detailRow.implicitWidth : 0
        clip:           true
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        RowLayout {
            id:      detailRow
            spacing: Theme.gap
            opacity: root.hovered ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

            Text {
                visible:        NetworkService.ip !== ""
                text:           " " + NetworkService.ip
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSm
                color:          Theme.fgDark
            }
            Text {
                visible:        NetworkService.signal > 0
                text:           "󰒢 " + NetworkService.signal + "%"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSm
                color:          Theme.fgDark
            }
        }
    }
}
