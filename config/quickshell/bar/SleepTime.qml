import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    spacing: Theme.paddingSm

    HoverHandler {
        onHoveredChanged: SleepTimeState.open = hovered
    }

    Text {
        text:           "󰒲"
        font.family:    Theme.iconFontFamily
        font.pixelSize: Theme.fontSm
        color:          SleepTimeState.open ? Theme.yellow : Theme.fgDark
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Text {
        text:           SleepTimeService.label
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.yellow
    }
}
