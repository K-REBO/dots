pragma Singleton

import QtQuick

QtObject {
    // ── Background ──────────────────────────────────────────────
    readonly property color bg:        "#07070e"
    readonly property color bgBar:     Qt.rgba(0.04, 0.04, 0.10, 0.72)
    readonly property color bgPill:    Qt.rgba(1,    1,    1,    0.09)
    readonly property color bgPillHov: Qt.rgba(1,    1,    1,    0.16)
    readonly property color bgLight:   Qt.rgba(0.12, 0.13, 0.20, 0.90)
    readonly property color bgHover:   Qt.rgba(0.15, 0.16, 0.26, 0.90)
    readonly property color border:    Qt.rgba(1,    1,    1,    0.12)
    readonly property color borderFoc: Qt.rgba(1,    1,    1,    0.22)
    readonly property color bgDark:    Qt.rgba(0.04, 0.04, 0.07, 0.96)

    // Accent pill backgrounds
    readonly property color bgPillCyan:    Qt.rgba(0.00, 0.83, 1.00, 0.12)
    readonly property color bgPillCyanHov: Qt.rgba(0.00, 0.83, 1.00, 0.20)
    readonly property color bgPillBlue:    Qt.rgba(0.18, 0.42, 0.85, 0.14)
    readonly property color bgPillBlueHov: Qt.rgba(0.18, 0.42, 0.85, 0.24)

    // ── Foreground ───────────────────────────────────────────────
    readonly property color fg:     "#dde3ff"
    readonly property color fgSub:  "#6870a0"
    readonly property color fgDark: "#6870a0"
    readonly property color fgDim:  "#2e3450"

    // ── Accent Colors ────────────────────────────────────────────
    readonly property color red:     "#ff5577"
    readonly property color green:   "#00e5aa"
    readonly property color yellow:  "#ffcc55"
    readonly property color blue:    "#4db8ff"
    readonly property color magenta: "#d080ff"
    readonly property color cyan:    "#00d4ff"
    readonly property color orange:  "#ff9944"
    readonly property color purple:  "#9966ff"
    readonly property color teal:    "#00e5cc"
    readonly property color pink:    "#ff80aa"

    // ── Workspace accent (per-ws) ────────────────────────────────
    readonly property var wsColors: [
        "#DC143C","#00FFFF","#FFD700","#0000FF",
        "#00FF00","#FF00FF","#FFFF00","#FF1493","#FF4500","#00FFFF",
    ]
    function wsColor(id) { return wsColors[(id - 1) % 10] }

    // ── Geometry ─────────────────────────────────────────────────
    readonly property real barHeight:  40
    readonly property real barMargin:  8
    readonly property real pillH:      28
    readonly property real radiusSm:   4
    readonly property real radiusWs:   6
    readonly property real radiusMd:   12
    readonly property real radiusLg:   18
    readonly property real radiusFull: 999

    // ── Spacing ──────────────────────────────────────────────────
    readonly property real paddingXs: 4
    readonly property real paddingSm: 8
    readonly property real paddingMd: 12
    readonly property real paddingLg: 18
    readonly property real gap:       6

    // ── Typography ───────────────────────────────────────────────
    readonly property string fontFamily:     "UbuntuMono Nerd Font"
    // アイコン専用フォント (Mono 版は Nerd Font 全 glyph を収録)
    readonly property string iconFontFamily: "UbuntuMono Nerd Font"
    readonly property real fontXs:  20
    readonly property real fontSm:  22
    readonly property real fontMd:  23
    readonly property real fontLg:  26
    readonly property real fontXl:  32

    // ── Animation ────────────────────────────────────────────────
    readonly property int animFast:   100
    readonly property int animNormal: 180
    readonly property int animSlow:   300
}
