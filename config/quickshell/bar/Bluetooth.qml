import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: Theme.paddingXs

    Text {
        text:           BluetoothService.icon
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontMd
        color: {
            if (!BluetoothService.powered)       return Theme.fgDim
            if (BluetoothService.connectedDevice) return Theme.blue
            return Theme.fg
        }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    BluetoothService.toggle()
        }
    }

    Text {
        visible:        BluetoothService.connectedDevice !== ""
        text:           BluetoothService.connectedDevice
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSm
        color:          Theme.fgDark
        Layout.maximumWidth: 80
        elide:          Text.ElideRight
    }
}
