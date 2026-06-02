import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: Theme.paddingSm

    readonly property var client: Hyprland.activeToplevel
    visible: client !== null && (client?.title ?? "") !== ""

    // アプリクラス → Nerd Font アイコン
    function appIcon(cls) {
        const map = {
            firefox:     "",  chromium:    "",
            alacritty:   "",  kitty:       "",  foot: "",
            code:       "󰨞",  codium:     "󰨞",
            spotify:     "",  discord:    "󰙯",
            telegram:    "",  obsidian:   "󰈄",
            nautilus:   "󰉓",  dolphin:    "󱔎",
            gimp:        "",  inkscape:    "",
            blender:    "󰂫",  emacs:      "",
            slack:       "",  zoom:        "",
        }
        const lower = (cls || "").toLowerCase()
        for (const [k, v] of Object.entries(map)) {
            if (lower.includes(k)) return v
        }
        return "󰘔"
    }

    Text {
        text:           root.appIcon(root.client?.wayland?.appId ?? "")
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color:          Theme.fgDark
    }

    Text {
        Layout.maximumWidth: 280
        text:               root.client?.title ?? ""
        font.family:        Theme.fontFamily
        font.pixelSize:     Theme.fontSm
        color:              Theme.fg
        elide:              Text.ElideRight
    }
}
