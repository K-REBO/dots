import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Hyprland

Rectangle {
    id: root

    required property var  workspace
    required property bool isActive

    readonly property color wsCol:    Theme.wsColor(workspace.id)
    readonly property var myToplevels: {
        const wsId = workspace.id
        return Hyprland.toplevels.values.filter(t => t.workspace?.id == wsId)
    }
    readonly property bool  occupied: myToplevels.length > 0

    readonly property string iconsStr: {
        const tls = myToplevels
        return Array.from(tls).map(tl => {
            const id = (tl.wayland?.appId ?? "").toLowerCase()
            if (id.includes("firefox"))                                                      return ""
            if (id.includes("alacritty"))                                                    return ""
            if (id.includes("spotify"))                                                      return ""
            if (id.includes("code") || id.includes("vscodium"))                             return ""
            if (id.includes("discord"))                                                      return ""
            if (id.includes("chromium") || id.includes("chrome"))                           return ""
            if (id.includes("thunar") || id.includes("nautilus") || id.includes("dolphin")) return ""
            if (id.includes("mpv"))                                                          return ""
            return ""
        }).join(" ")
    }

    implicitHeight: 24
    implicitWidth:  _wsRow.implicitWidth + 14

    radius: Theme.radiusSm

    color: isActive
        ? wsCol
        : (occupied ? Qt.rgba(wsCol.r, wsCol.g, wsCol.b, 0.20) : Qt.rgba(1,1,1,0.04))

    border.color: isActive
        ? Qt.darker(wsCol, 1.1)
        : (occupied ? Qt.rgba(wsCol.r, wsCol.g, wsCol.b, 0.45) : Qt.rgba(1,1,1,0.07))
    border.width: 1

    Behavior on color        { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

    RowLayout {
        id:              _wsRow
        anchors.centerIn: parent
        spacing:          3

        Text {
            text:           root.workspace.id
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSm
            font.bold:      root.isActive
            color:          root.isActive ? "#000000"
                          : (root.occupied ? root.wsCol : Theme.fgDark)
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }

        Text {
            text:           "[" + root.iconsStr + "]"
            visible:        root.occupied
            font.family:    Theme.iconFontFamily
            font.pixelSize: Theme.fontSm
            color:          root.isActive ? "#000000" : root.wsCol
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    Hyprland.dispatch("workspace " + root.workspace.id)
    }
}
