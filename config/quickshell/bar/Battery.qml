import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

Item {
    implicitWidth:  _row.implicitWidth
    implicitHeight: _row.implicitHeight

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    TlpService.cycleProfile()
    }

    RowLayout {
        id:      _row
        spacing: Theme.paddingXs

        // ── TLP プロファイルアイコン ───────────────────────────────
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

        // ── バッテリーアイコン ─────────────────────────────────────
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

        // ── パーセント ─────────────────────────────────────────────
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

        // ── 残り時間 ───────────────────────────────────────────────
        Text {
            visible:        BatteryService.timeLeft !== ""
            text:           "(" + BatteryService.timeLeft + ")"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSm - 1
            color:          Theme.fgDim
        }
    }
}
