import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    spacing: Theme.paddingXs

    Text {
        text:           BatteryService.icon
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color: {
            if (BatteryService.status === "Charging") return Theme.green
            if (BatteryService.percent <= 15)         return Theme.red
            if (BatteryService.percent <= 35)         return Theme.yellow
            return Theme.fg
        }
        Behavior on color { ColorAnimation { duration: 500 } }
    }

    Text {
        text:           BatteryService.percent + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          BatteryService.percent <= 15 ? Theme.red : Theme.fgDark
        Behavior on color { ColorAnimation { duration: 500 } }
    }

    Text {
        visible:        BatteryService.timeLeft !== ""
        text:           "(" + BatteryService.timeLeft + ")"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm - 1
        color:          Theme.fgDim
    }
}
