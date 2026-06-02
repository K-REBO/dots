import QtQuick
import ".."
import "../services"

Rectangle {
    id: root
    implicitWidth:  Theme.pillH
    implicitHeight: Theme.pillH
    radius:         Theme.radiusWs
    color:          Theme.bgLight

    Text {
        anchors.centerIn: parent
        text:             ImeService.mode
        font.family:      Theme.fontFamily
        font.pixelSize:   Theme.fontSm
        font.bold:        true
        color:            Theme.yellow
    }

    HoverHandler { id: hov }

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
