import QtQuick
import ".."

// 汎用ピル型コンテナ
Rectangle {
    id: root

    default property alias content: root.data

    implicitWidth:  innerContent.implicitWidth + Theme.paddingMd * 2
    implicitHeight: Theme.pillH
    radius:         Theme.radiusFull
    color:          hov.hovered ? Theme.bgPillHov : Theme.bgPill

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    HoverHandler { id: hov }

    Item {
        id: innerContent
        anchors.centerIn: parent
        implicitWidth:    children.length > 0 ? children[0].implicitWidth : 0
        implicitHeight:   Theme.pillH
    }
}
