import QtQuick
import ".."
import "../services"

Rectangle {
    id: root
    implicitWidth:  28
    implicitHeight: 24
    radius:         Theme.radiusSm

    color: ImeService.mode === "あ"
        ? Qt.rgba(0, 0.67, 1, 0.18)
        : Qt.rgba(1, 1, 1, 0.05)

    border.color: ImeService.mode === "あ" ? Theme.blue : Theme.border
    border.width: 1

    Behavior on color       { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    Text {
        anchors.centerIn: parent
        text:             ImeService.icon
        font.family:      Theme.fontFamily
        font.pixelSize:   Theme.fontSm
        font.bold:        ImeService.mode === "あ"
        color:            ImeService.mode === "あ" ? Theme.blue : Theme.fgDark
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    HoverHandler { id: hov }

    // ホバーハイライト
    Rectangle {
        anchors.fill: parent
        radius:       parent.radius
        color:        Qt.rgba(1,1,1,0.05)
        opacity:      hov.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    ImeService.toggle()
    }
}
