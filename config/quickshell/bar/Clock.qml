import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

RowLayout {
    id: root
    spacing: Theme.paddingSm

    SystemClock {
        id: _clock
        precision: SystemClock.Seconds
    }

    MouseArea {
        cursorShape:    Qt.PointingHandCursor
        implicitWidth:  _row.implicitWidth
        implicitHeight: _row.implicitHeight
        onClicked:      CalendarState.toggle()

        RowLayout {
            id: _row
            spacing: Theme.paddingSm

            Text {
                text:           ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontMd
                color:          CalendarState.open ? Theme.cyan : Theme.fgDark
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            Text {
                text:           Qt.formatDate(_clock.date, "MM/dd ddd")
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSm
                color:          Theme.fgDark
            }

            Text {
                text:           Qt.formatTime(_clock.date, "HH:mm")
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontMd
                font.bold:      true
                color:          Theme.fg
            }
        }
    }
}
