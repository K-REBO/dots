import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

// ── 通知ベルウィジェット（pill + dropdown 一体型）───────────────────
//
// GithubIssues と同じ構造。Bar.qml の _notifSpacer が幅を確保し、
// PanelWindow がその右端に位置合わせされる。
PanelWindow {
    id: root
    required property var screen

    anchors { top: true; right: true }
    margins {
        top:   Theme.barMargin + (Theme.barHeight - Theme.pillH) / 2
        right: NotificationState.marginRight > 0
               ? NotificationState.marginRight
               : (Theme.barMargin + 14)
    }

    readonly property real _expandedW:  320
    readonly property real _collapsedW: Theme.fontMd + 20

    implicitWidth:  _expandedW
    implicitHeight: Theme.pillH + 420
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    mask: Region {
        x:      _widget.x
        y:      0
        width:  _widget.width
        height: _widget.height
    }

    Binding { target: NotificationState; property: "pillWidth"; value: _widget.width }

    // ── ウィジェット本体 ──────────────────────────────────────────
    Rectangle {
        id: _widget

        anchors { top: parent.top; right: parent.right }

        width: NotificationState.open ? root._expandedW : root._collapsedW
        Behavior on width {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        height: NotificationState.open
                ? (Theme.pillH + 1 + _dropContent.implicitHeight + 16)
                : Theme.pillH
        Behavior on height {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgLight
        border.color: Theme.blue
        border.width: NotificationState.open ? 1 : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        HoverHandler {
            onHoveredChanged: {
                NotificationState.open = hovered
                if (hovered) NotificationState.markAllRead()
            }
        }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // ── ピル行 ────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight:   Theme.pillH

                // 横展開エリア: 通知件数（左寄せ、展開時のみ表示）
                Item {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Theme.paddingMd }
                    width:  NotificationState.open ? _countText.implicitWidth : 0
                    height: Theme.pillH
                    clip:   true
                    Behavior on width {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                    }

                    Text {
                        id: _countText
                        anchors.verticalCenter: parent.verticalCenter
                        text:           NotificationState.history.length + "件"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.fg
                        opacity:        NotificationState.open ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    }
                }

                // 全消去ボタン（中央寄せ、展開時のみ表示）
                Rectangle {
                    visible:        NotificationState.open && NotificationState.history.length > 0
                    anchors.centerIn: parent
                    implicitWidth:  26
                    implicitHeight: 24
                    radius:         Theme.radiusSm
                    color:          _clearHov.hovered ? Theme.bgPillHov : "transparent"
                    opacity:        NotificationState.open ? 1 : 0
                    Behavior on color   { ColorAnimation  { duration: Theme.animFast } }
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                    HoverHandler { id: _clearHov }

                    Text {
                        anchors.centerIn: parent
                        text:           "󰆴"
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.red
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    NotificationState.clearHistory()
                    }
                }

                // ベルアイコン（右寄せ）
                Text {
                    id: _bellIcon
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: Theme.paddingMd }
                    text:           NotificationState.doNotDisturb ? "󰂛" : "󰂚"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                    color:          NotificationState.open       ? Theme.blue
                                  : NotificationState.doNotDisturb ? Theme.fgSub
                                  :                                   Theme.fg
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }

                // 未読バッジ
                Rectangle {
                    visible: NotificationState.unreadCount > 0 && !NotificationState.open
                    anchors { top: parent.top; right: parent.right; topMargin: 2; rightMargin: 2 }
                    implicitWidth:  Math.max(14, _badgeNum.implicitWidth + 6)
                    implicitHeight: 14
                    radius:         Theme.radiusFull
                    color:          Theme.red

                    Text {
                        id: _badgeNum
                        anchors.centerIn: parent
                        text:           NotificationState.unreadCount > 9 ? "9+" : NotificationState.unreadCount
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontXs - 4
                        color:          "#ffffff"
                        font.bold:      true
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
                opacity:          NotificationState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            // ── ドロップダウンコンテンツ ──────────────────────────
            ColumnLayout {
                id:                 _dropContent
                Layout.fillWidth:    true
                Layout.minimumWidth: 0
                Layout.topMargin:   8
                Layout.leftMargin:  10
                Layout.rightMargin: 10
                spacing:            4
                opacity:            NotificationState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                // ── ヘッダー: タイトル + DNDトグル ────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing:          8

                    Text {
                        text:             "通知"
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSm
                        font.bold:        true
                        color:            Theme.fg
                        Layout.fillWidth: true
                    }

                    // DNDトグル
                    Rectangle {
                        implicitWidth:  _dndLabel.implicitWidth + Theme.paddingMd
                        implicitHeight: 24
                        radius:         Theme.radiusFull
                        color:          NotificationState.doNotDisturb ? Theme.bgPillCyan : Theme.bgPill

                        Text {
                            id: _dndLabel
                            anchors.centerIn: parent
                            text:           NotificationState.doNotDisturb ? "󰂛 DND ON" : "󰂚 DND OFF"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontXs - 1
                            color:          NotificationState.doNotDisturb ? Theme.cyan : Theme.fgSub
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    NotificationState.toggleDnd()
                        }
                    }
                }

                // ── 空状態 ───────────────────────────────────────
                Text {
                    visible:          NotificationState.history.length === 0
                    text:             "通知はありません"
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSm
                    color:            Theme.fgSub
                    Layout.fillWidth: true
                }

                // ── 履歴リスト（スクロール可能）──────────────────
                Item {
                    Layout.fillWidth:       true
                    Layout.preferredHeight: Math.min(_histColumn.implicitHeight, 280)
                    visible:                NotificationState.history.length > 0

                    Flickable {
                        id: _histFlick
                        anchors.fill:   parent
                        contentWidth:   width
                        contentHeight:  _histColumn.implicitHeight
                        clip:           true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id:      _histColumn
                            width:   _histFlick.width
                            spacing: 4

                            Repeater {
                                model: NotificationState.history

                                delegate: Rectangle {
                                    id: _row
                                    required property var modelData

                                    Layout.fillWidth: true
                                    implicitHeight:   _histCol.implicitHeight + 12
                                    radius:           Theme.radiusSm
                                    color:            _histHov.hovered ? Theme.bgHover : "transparent"
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                    HoverHandler { id: _histHov }

                                    ColumnLayout {
                                        id: _histCol
                                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            Rectangle {
                                                implicitWidth:  6
                                                implicitHeight: 6
                                                radius:         3
                                                color:          _row.modelData.urgency === NotificationUrgency.Critical ? Theme.red
                                                              : _row.modelData.urgency === NotificationUrgency.Low       ? Theme.fgDim
                                                              :                                                             Theme.cyan
                                            }

                                            Text {
                                                text:             _row.modelData.appName
                                                font.family:      Theme.fontFamily
                                                font.pixelSize:   Theme.fontXs
                                                color:            Theme.fgSub
                                                Layout.fillWidth: true
                                                elide:            Text.ElideRight
                                            }

                                            Text {
                                                text:           NotificationState.relativeTime(_row.modelData.time)
                                                font.family:    Theme.fontFamily
                                                font.pixelSize: Theme.fontXs
                                                color:          Theme.fgDim
                                            }
                                        }

                                        Text {
                                            visible:          _row.modelData.summary !== ""
                                            text:             _row.modelData.summary
                                            font.family:      Theme.fontFamily
                                            font.pixelSize:   Theme.fontSm
                                            font.bold:        true
                                            color:            Theme.fg
                                            Layout.fillWidth: true
                                            elide:            Text.ElideRight
                                        }

                                        Text {
                                            visible:          _row.modelData.body !== ""
                                            text:             _row.modelData.body
                                            font.family:      Theme.fontFamily
                                            font.pixelSize:   Theme.fontXs
                                            color:            Theme.fgSub
                                            Layout.fillWidth: true
                                            wrapMode:         Text.Wrap
                                            maximumLineCount: 2
                                            elide:            Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // スクロールインジケーター
                    Rectangle {
                        visible: _histFlick.contentHeight > _histFlick.height
                        anchors { top: parent.top; right: parent.right; rightMargin: 1 }
                        y:       _histFlick.visibleArea.yPosition * _histFlick.height
                        width:   3
                        height:  _histFlick.visibleArea.heightRatio * _histFlick.height
                        radius:  1.5
                        color:   Theme.fgDim
                        opacity: 0.5
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }
}
