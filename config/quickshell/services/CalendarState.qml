pragma Singleton

import QtQuick

QtObject {
    property bool open:           false
    property real clockPillWidth: 0
    function toggle()  { open = !open }
    function close()   { open = false }
}
