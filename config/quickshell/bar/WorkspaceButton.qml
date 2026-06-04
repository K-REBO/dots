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

    readonly property string _iconBase:
        "/etc/profiles/per-user/bido/share/icons/Colloid-Dark/apps/scalable/"

    function _appIcon(appId) {
        const id = appId.toLowerCase()
        if (id.includes("firefox"))    return { svg: _iconBase + "firefox.svg",             nf: "󰈹" }
        if (id.includes("alacritty"))  return { svg: _iconBase + "alacritty.svg",            nf: "󰆍" }
        if (id.includes("spotify"))    return { svg: _iconBase + "spotify-client.svg",       nf: "󰓇" }
        if (id.includes("code") || id.includes("vscodium"))
                                       return { svg: _iconBase + "visual-studio-code.svg",   nf: "󰨞" }
        if (id.includes("discord"))    return { svg: _iconBase + "discord.svg",              nf: "󰙯" }
        if (id.includes("slack"))      return { svg: _iconBase + "slack.svg",                nf: "󰒱" }
        if (id.includes("telegram"))   return { svg: _iconBase + "telegram.svg",             nf: "󰔁" }
        if (id.includes("chromium"))   return { svg: _iconBase + "chromium.svg",             nf: "󰊯" }
        if (id.includes("chrome"))     return { svg: _iconBase + "google-chrome.svg",        nf: "󰊯" }
        if (id.includes("thunar") || id.includes("nautilus") || id.includes("dolphin") || id.includes("pcmanfm"))
                                       return { svg: _iconBase + "system-file-manager.svg",  nf: "󰉋" }
        if (id.includes("obsidian"))   return { svg: _iconBase + "obsidian.svg",             nf: "󱓧" }
        if (id.includes("mpv"))        return { svg: _iconBase + "mpv.svg",                  nf: "󰕧" }
        if (id.includes("steam"))      return { svg: _iconBase + "steam.svg",                nf: "󰓓" }
        return                                { svg: _iconBase + "application-default-icon.svg", nf: "󰀏" }
    }

    readonly property var iconUrls: Array.from(myToplevels).map(
        tl => _appIcon(tl.wayland?.appId ?? "").svg)

    readonly property string iconsStr: Array.from(myToplevels).map(
        tl => _appIcon(tl.wayland?.appId ?? "").nf).join(" ")

    implicitHeight: Theme.pillH - 6
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

        Repeater {
            model: root.occupied && Theme.wsIconMode === "svg" ? root.iconUrls : []
            Image {
                required property string modelData
                source:     "file://" + modelData
                sourceSize: Qt.size(30, 30)
                fillMode:   Image.PreserveAspectFit
                smooth:     true
                mipmap:     true
                Layout.preferredWidth:  30
                Layout.preferredHeight: 30
                Layout.maximumWidth:    30
                Layout.maximumHeight:   30
            }
        }

        Text {
            text:           root.iconsStr
            visible:        root.occupied && Theme.wsIconMode === "nerdfont"
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
