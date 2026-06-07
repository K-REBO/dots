import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

// ═══════════════════════════════════════════════════════════════════
// TemplateWidget — pill + dropdown 一体型ウィジェットのテンプレート
// ※ このファイルは現在バーから外れています。新ウィジェットの雛形として使用してください。
//
// 使い方:
//   1. TemplateWidget.qml → MyWidget.qml にコピー
//   2. TemplateState.qml  → MyWidgetState.qml にコピー（TemplateState → MyWidgetState に置換）
//   3. services/qmldir に `singleton MyWidgetState 1.0 MyWidgetState.qml` を追加
//   4. bar/qmldir に `MyWidget 1.0 MyWidget.qml` を追加
//   5. Bar.qml の右セクションにスペーサー Item を追加（_tmplSpacer パターンを参考）
//   6. shell.qml に Variants ブロックを追加
//
// 構造:
//   Bar.qml に透明スペーサー（TemplateState.pillWidth）を置いて
//   他の pill と重ならないようにしつつ、PanelWindow は pill の真上から
//   開始することで pill → dropdown が一体に見える。
//
// 位置:
//   margins.top  = pill の上端（barMargin + (barHeight - pillH) / 2）
//   margins.right = barMargin + 14 + clockPillWidth + gap（Clock 左隣）
PanelWindow {
    id: root
    required property var screen

    anchors { top: true; right: true }
    margins {
        top:   Theme.barMargin + (Theme.barHeight - Theme.pillH) / 2
        right: TemplateState.marginRight > 0
               ? TemplateState.marginRight
               : (Theme.barMargin + 14 + CalendarState.clockPillWidth + Theme.gap)
    }

    readonly property real _expandedW:  240
    readonly property real _collapsedW: Theme.fontMd + 20  // icon + 水平 padding

    implicitWidth:  _expandedW
    implicitHeight: Theme.pillH + 300   // pill 分 + dropdown 最大高
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    mask: Region {
        x:      _widget.x
        y:      0
        width:  _widget.width
        height: _widget.height
    }

    // _widget の現在幅（アニメ中も含む）を Bar.qml スペーサーへ転送
    Binding { target: TemplateState; property: "pillWidth"; value: _widget.width }

    // ── ウィジェット本体（pill 上端から下方向に伸びる）────────────
    Rectangle {
        id: _widget

        anchors { top: parent.top; right: parent.right }

        // 幅: icon のみ → 展開幅
        width: TemplateState.open ? root._expandedW : root._collapsedW
        Behavior on width {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        // 高さ: pill のみ → pill + セパレーター + dropdown
        height: TemplateState.open
                ? (Theme.pillH + 1 + _dropContent.implicitHeight + 16)
                : Theme.pillH
        Behavior on height {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgLight
        border.color: Theme.cyan
        border.width: TemplateState.open ? 1 : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        HoverHandler {
            onHoveredChanged: TemplateState.open = hovered
        }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // ── ピル行 ────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight:   Theme.pillH

                RowLayout {
                    anchors.centerIn: parent
                    spacing:          Theme.paddingXs

                    // 横展開エリア（Volume のスライダー位置相当）
                    Item {
                        implicitWidth:  TemplateState.open ? _pillContent.implicitWidth : 0
                        implicitHeight: Theme.pillH
                        clip: true
                        Behavior on implicitWidth {
                            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                        }

                        // ── ここに横展開コンテンツを実装 ─────────
                        RowLayout {
                            id:      _pillContent
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.paddingXs

                            Text {
                                text:           "テンプレート"
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                color:          Theme.fg
                                opacity:        TemplateState.open ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                            }
                        }
                    }

                    // アイコン
                    Text {
                        text:           ""
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontMd
                        color:          TemplateState.open ? Theme.cyan : Theme.fg
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
                opacity:          TemplateState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            // ── ドロップダウンコンテンツ ──────────────────────────
            ColumnLayout {
                id:                 _dropContent
                Layout.fillWidth:   true
                Layout.topMargin:   8
                Layout.leftMargin:  12
                Layout.rightMargin: 12
                spacing:            6
                opacity:            TemplateState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                // ── ここにドロップダウンアイテムを実装 ───────────
                Repeater {
                    model: [
                        { icon: "", label: "アイテム 1" },
                        { icon: "", label: "アイテム 2" },
                        { icon: "", label: "アイテム 3" },
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight:   32
                        radius:           Theme.radiusSm
                        color:            _rowHov.hovered ? Theme.bgHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        HoverHandler { id: _rowHov }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    TemplateState.open = false
                        }

                        RowLayout {
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                            spacing: 8

                            Text {
                                text:           modelData.icon
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                color:          Theme.cyan
                            }
                            Text {
                                text:             modelData.label
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontSm
                                color:            Theme.fg
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }
}
