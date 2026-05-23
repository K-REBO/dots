import QtQuick
import ".."
import "../services"
import Quickshell.Hyprland

Rectangle {
    id: root

    required property var  workspace
    required property bool isActive

    readonly property color wsCol: Theme.wsColor(workspace.id)

    width:  26
    height: 26
    radius: Theme.radiusFull

    readonly property bool occupied: (workspace.toplevels?.values?.length ?? 0) > 0

    color: isActive
        ? Qt.rgba(wsCol.r, wsCol.g, wsCol.b, 0.22)
        : (occupied ? Qt.rgba(1,1,1,0.05) : "transparent")

    border.color: isActive
        ? wsCol
        : (occupied ? Qt.rgba(1,1,1,0.18) : Qt.rgba(1,1,1,0.06))
    border.width: 1.5

    Behavior on color       { ColorAnimation  { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    Text {
        anchors.centerIn: parent
        text:             root.workspace.id
        font.family:      Theme.fontFamily
        font.pixelSize:   Theme.fontSm
        font.bold:        root.isActive
        color:            root.isActive ? root.wsCol : Theme.fgDark

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    // ── Hover highlight ──────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       parent.radius
        color:        Qt.rgba(1,1,1,0.06)
        opacity:      hov.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }
    HoverHandler { id: hov }

    // ── Click → switch ───────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    Hyprland.dispatch("workspace " + root.workspace.id)
    }
}
