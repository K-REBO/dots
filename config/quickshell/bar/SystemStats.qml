import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    spacing: Theme.paddingSm

    // ── CPU ───────────────────────────────────────────────────────
    Text {
        text:           "󰻠"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color: {
            if (SystemStatsService.cpuPercent >= 80) return Theme.red
            if (SystemStatsService.cpuPercent >= 60) return Theme.yellow
            return Theme.green
        }
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    Text {
        text:           SystemStatsService.cpuPercent + "%"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fg
    }

    // ── セパレーター ──────────────────────────────────────────────
    Rectangle {
        width:  1
        height: 14
        color:  Theme.border
    }

    // ── メモリ ────────────────────────────────────────────────────
    Text {
        text:           "󰑭"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color: {
            if (SystemStatsService.memPercent >= 85) return Theme.red
            if (SystemStatsService.memPercent >= 70) return Theme.yellow
            return Theme.blue
        }
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    Text {
        text:           SystemStatsService.memUsedGb + "G"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fg
    }
}
