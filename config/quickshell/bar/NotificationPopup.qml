import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

// ── 通知トースト（画面右上にスタック表示）─────────────────────────
PanelWindow {
    id: root

    required property var screen

    WlrLayershell.namespace: "quickshell-notification"
    WlrLayershell.layer:     WlrLayer.Overlay

    anchors { top: true; right: true }
    margins {
        top:   Theme.barMargin * 2 + Theme.barHeight
        right: Theme.barMargin
    }

    implicitWidth:  380
    implicitHeight: Math.max(1, _col.implicitHeight)
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore
    visible:        NotificationState.popups.length > 0

    mask: Region { item: _col }

    ColumnLayout {
        id:      _col
        width:   parent.width
        spacing: Theme.gap

        Repeater {
            model: NotificationState.popups

            delegate: Rectangle {
                id: _toast
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: _content.implicitHeight + Theme.paddingMd * 2
                radius:         Theme.radiusMd
                color:          Theme.bgPanel
                border.width:   1
                border.color:   _toast.modelData.urgency === NotificationUrgency.Critical ? Theme.red
                              : _toast.modelData.urgency === NotificationUrgency.Low       ? Theme.border
                              :                                                              Theme.borderFoc

                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

                Timer {
                    interval: _toast.modelData.timeout
                    running:  _toast.modelData.timeout > 0 && !_hov.hovered
                    onTriggered: NotificationState.expirePopup(_toast.modelData.key)
                }

                HoverHandler { id: _hov }

                // トースト全面: クリックで消去（アクションボタン等は子が優先して受ける）
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    NotificationState.dismiss(_toast.modelData.key)
                }

                ColumnLayout {
                    id: _content
                    anchors {
                        left:           parent.left
                        right:          parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin:     Theme.paddingMd
                        rightMargin:    Theme.paddingMd
                    }
                    spacing: 6

                    // ── ヘッダー行: アイコン + アプリ名 + 閉じるボタン ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        IconImage {
                            visible: source !== ""
                            implicitSize: Theme.fontLg
                            source: _toast.modelData.image !== ""   ? _toast.modelData.image
                                  : _toast.modelData.appIcon !== "" ? Quickshell.iconPath(_toast.modelData.appIcon)
                                  :                                   ""
                        }

                        Text {
                            text:             _toast.modelData.appName
                            font.family:      Theme.fontFamily
                            font.pixelSize:   Theme.fontXs
                            color:            Theme.fgSub
                            Layout.fillWidth: true
                            elide:            Text.ElideRight
                        }

                        Text {
                            text:           "✕"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontXs
                            color:          Theme.fgSub

                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -6
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       NotificationState.dismiss(_toast.modelData.key)
                            }
                        }
                    }

                    // ── サマリー ─────────────────────────────────
                    Text {
                        visible:          _toast.modelData.summary !== ""
                        text:             _toast.modelData.summary
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSm
                        font.bold:        true
                        color:            Theme.fg
                        Layout.fillWidth: true
                        wrapMode:         Text.Wrap
                        maximumLineCount: 2
                        elide:            Text.ElideRight
                    }

                    // ── 本文 ─────────────────────────────────────
                    Text {
                        visible:          _toast.modelData.body !== ""
                        text:             _toast.modelData.body
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontXs
                        color:            Theme.fgSub
                        Layout.fillWidth: true
                        wrapMode:         Text.Wrap
                        maximumLineCount: 4
                        elide:            Text.ElideRight
                    }

                    // ── アクションボタン ──────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing:          6
                        visible:          _actionsRepeater.count > 0

                        Item { Layout.fillWidth: true }

                        Repeater {
                            id:    _actionsRepeater
                            model: _toast.modelData.actions

                            delegate: Rectangle {
                                id: _action
                                required property var modelData

                                implicitWidth:  _aLabel.implicitWidth + Theme.paddingMd * 2
                                implicitHeight: 26
                                radius:         Theme.radiusSm
                                color:          _aHov.hovered ? Theme.bgPillHov : Theme.bgPill

                                HoverHandler { id: _aHov }

                                Text {
                                    id: _aLabel
                                    anchors.centerIn: parent
                                    text:             _action.modelData.text
                                    font.family:      Theme.fontFamily
                                    font.pixelSize:   Theme.fontXs
                                    color:            Theme.fg
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    NotificationState.invokeAction(_toast.modelData.key, _action.modelData.identifier)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
