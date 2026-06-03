pragma Singleton

import QtQuick

QtObject {
    // ── Background ──────────────────────────────────────────────
    readonly property color bg:        "#07070e"
    readonly property color bgBar:     Qt.rgba(0.04, 0.04, 0.10, 0.72)
    readonly property color bgPill:    Qt.rgba(1,    1,    1,    0.09)
    readonly property color bgPillHov: Qt.rgba(1,    1,    1,    0.16)
    readonly property color bgLight:   Qt.rgba(0.10, 0.11, 0.18, 0.90)  // eww $bg-light
    readonly property color bgHover:   Qt.rgba(0.13, 0.14, 0.22, 0.90)
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
    function wsColor(id) { return Qt.color(wsColors[(id - 1) % 10]) }
    function wsColorAlpha(id, alpha) {
        const c = Qt.color(wsColors[(id - 1) % 10])
        return Qt.rgba(c.r, c.g, c.b, alpha)
    }

    // ── Geometry ─────────────────────────────────────────────────
    readonly property real barHeight:  54
    readonly property real barMargin:  6
    readonly property real pillH:      40
    readonly property real radiusSm:   4
    readonly property real radiusWs:   6
    readonly property real radiusMd:   8
    readonly property real radiusLg:   12
    readonly property real radiusFull: 999

    // ── Spacing ──────────────────────────────────────────────────
    readonly property real paddingXs: 4
    readonly property real paddingSm: 8
    readonly property real paddingMd: 12
    readonly property real paddingLg: 18
    readonly property real gap:       10

    // ── Workspace Icons ──────────────────────────────────────────
    // "svg" = Colloid-Dark SVGアイコン / "nerdfont" = Nerd Fontグリフ
    readonly property string wsIconMode: "svg"

    // ── Typography ───────────────────────────────────────────────
    // ewwと同じフォントファミリー
    readonly property string fontFamily:     "JetBrainsMono NF"
    readonly property string iconFontFamily: "JetBrainsMono NF"
    readonly property real fontXs:  16
    readonly property real fontSm:  18
    readonly property real fontMd:  20
    readonly property real fontLg:  22
    readonly property real fontXl:  35

    // ── Animation ────────────────────────────────────────────────
    readonly property int animFast:   100
    readonly property int animNormal: 300
    readonly property int animSlow:   450
}
