import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    spacing: Theme.paddingSm

    HoverHandler {
        onHoveredChanged: BatteryState.open = hovered
    }

    Text {
        text: {
            switch (TlpService.currentProfile) {
                case "performance": return "󱐋"
                case "balanced":    return "󰾆"
                case "low-power":   return "󰌱"
                default:            return "󰾆"
            }
        }
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color: {
            switch (TlpService.currentProfile) {
                case "performance": return Theme.orange
                case "balanced":    return Theme.yellow
                case "low-power":   return Theme.green
                default:            return Theme.fgDim
            }
        }
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    Text {
        text:           BatteryService.icon
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color: {
            if (BatteryService.status === "Charging") return Theme.green
            if (BatteryService.percent <= 15)         return Theme.red
            if (BatteryService.percent <= 35)         return Theme.yellow
            return Theme.blue
        }
        Behavior on color { ColorAnimation { duration: 500 } }
    }

    Text {
        text:           BatteryService.percent + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color: {
            if (BatteryService.status === "Charging") return Theme.green
            if (BatteryService.percent <= 15)         return Theme.red
            if (BatteryService.percent <= 35)         return Theme.yellow
            return Theme.blue
        }
        Behavior on color { ColorAnimation { duration: 500 } }
    }

    Text {
        visible:        BatteryService.timeLeft !== ""
        text:           BatteryService.timeLeft
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm - 1
        color:          Theme.fgDim
    }
}
