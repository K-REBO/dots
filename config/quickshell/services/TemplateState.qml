pragma Singleton

import QtQuick

QtObject {
    property bool open:        false
    property real pillWidth:   0     // TemplateWidget のアニメ中の width を Bar.qml スペーサーへ転送
    property real marginRight: 0     // Bar.qml スペーサーの実測右マージン → PanelWindow 位置合わせ
}
