import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingSm

    property bool expanded: false

    HoverHandler {
        id: hov
        onHoveredChanged: root.expanded = hov.hovered
    }

    // ── TLP プロファイルアイコン ───────────────────────────────────
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

    // ── バッテリーアイコン ─────────────────────────────────────────
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

    // ── パーセント ─────────────────────────────────────────────────
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

    // ── 残り時間 ───────────────────────────────────────────────────
    Text {
        visible:        BatteryService.timeLeft !== ""
        text:           "(" + BatteryService.timeLeft + ")"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm - 1
        color:          Theme.yellow
    }

    // ── ホバーで展開するプロファイル選択 ──────────────────────────
    Item {
        enabled:       expanded
        height:        Theme.pillH
        implicitWidth: expanded ? _menu.implicitWidth + Theme.paddingSm : 0
        clip:          true
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        RowLayout {
            id:      _menu
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.paddingXs

            Rectangle { width: 1; height: 18; color: Theme.border }

            Repeater {
                model: [
                    { label: "performance", profile: "performance", accent: Theme.orange  },
                    { label: "balanced",    profile: "balanced",    accent: Theme.yellow  },
                    { label: "low-power",   profile: "low-power",   accent: Theme.green   },
                ]

                delegate: Rectangle {
                    required property var modelData

                    readonly property bool  isCurrent: TlpService.currentProfile === modelData.profile
                    readonly property color accent:    modelData.accent

                    implicitWidth:  _label.implicitWidth + Theme.paddingMd
                    implicitHeight: 22
                    radius:         Theme.radiusSm
                    color: {
                        if (_bhov.hovered) return Qt.rgba(accent.r, accent.g, accent.b, 0.18)
                        if (isCurrent)     return Qt.rgba(accent.r, accent.g, accent.b, 0.12)
                        return "transparent"
                    }
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    border.color: isCurrent
                        ? Qt.rgba(accent.r, accent.g, accent.b, 0.5)
                        : "transparent"
                    border.width: 1

                    Text {
                        id:               _label
                        anchors.centerIn: parent
                        text:             modelData.label
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSm
                        font.bold:        isCurrent
                        color:            isCurrent ? accent : Theme.fgDark
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    HoverHandler { id: _bhov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    TlpService.setProfile(modelData.profile)
                    }
                }
            }
        }
    }
}
