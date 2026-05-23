import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell

RowLayout {
    id: root
    spacing: Theme.paddingSm

    // カレンダーポップアップ表示フラグ（Barから参照される）
    property bool calendarOpen: false

    // Barから参照できるよう公開
    readonly property SystemClock sysClock: _clock

    SystemClock {
        id: _clock
        precision: SystemClock.Seconds
    }

    MouseArea {
        cursorShape:    Qt.PointingHandCursor
        implicitWidth:  _row.implicitWidth
        implicitHeight: _row.implicitHeight
        onClicked:      root.calendarOpen = !root.calendarOpen

        RowLayout {
            id: _row
            spacing: Theme.paddingSm

            Text {
                text:           ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontMd
                color:          Theme.fgDark
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
