import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingXs

    property bool hovered: false

    HoverHandler { onHoveredChanged: root.hovered = hovered }

    // アイコン（クリックで電源トグル）
    Text {
        text:           BluetoothService.icon
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color: BluetoothService.powered ? Theme.red : Theme.fgDim
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    BluetoothService.toggle()
        }
    }

    // ホバー時のみ接続デバイス名を展開
    Item {
        implicitHeight: deviceText.implicitHeight
        implicitWidth:  (root.hovered && BluetoothService.connectedDevice !== "")
                        ? deviceText.implicitWidth : 0
        clip:           true
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        Text {
            id:             deviceText
            text:           BluetoothService.connectedDevice
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSm
            color:          Theme.fgDark
            opacity:        root.hovered ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        }
    }
}
