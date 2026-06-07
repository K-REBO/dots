// TemplateWidget 用の状態管理 Singleton。新ウィジェット作成時の雛形。
// TemplateWidget.qml のコメントを参照。
pragma Singleton

import QtQuick

QtObject {
    property bool open:        false
    property real pillWidth:   0     // TemplateWidget のアニメ中の width を Bar.qml スペーサーへ転送
    property real marginRight: 0     // Bar.qml スペーサーの実測右マージン → PanelWindow 位置合わせ
}
