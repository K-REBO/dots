import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

PanelWindow {
    id: root

    required property var screen

    anchors { top: true; left: true }
    margins {
        top:  Theme.barHeight + Theme.barMargin * 3
        left: screen ? Math.max(0, (screen.width - 400) / 2) : 0
    }

    implicitWidth:  400
    implicitHeight: Math.min(_col.implicitHeight + 28, 520)
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    // フェードアウト完了まで Window を保持
    property real contentOpacity: FileDropState.hovered ? 1.0 : 0.0
    Behavior on contentOpacity {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }
    visible: contentOpacity > 0

    // ドロップダウン演出用オフセット（root スコープで定義し Translate から参照）
    property real dropOffset: FileDropState.hovered ? 0 : -10
    Behavior on dropOffset {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    // ── 背景 ─────────────────────────────────────────────────────
    Rectangle {
        anchors { fill: parent; margins: 6 }
        radius:       Theme.radiusMd
        color:        Theme.bgPanel
        border.color: Theme.border
        border.width: 1
        opacity:      root.contentOpacity
        transform:    Translate { y: root.dropOffset }

        // 2ゾーンホバー: popup 内にいる間もタイマーをキャンセル
        HoverHandler {
            onHoveredChanged: {
                if (hovered) FileDropState.startHover()
                else         FileDropState.endHover()
            }
        }

        Flickable {
            anchors { fill: parent; margins: 1 }
            contentHeight: _col.implicitHeight + 28
            clip:          true

            ColumnLayout {
                id:      _col
                width:   parent.width
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
                spacing: 10

                // ── ヘッダー ─────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text:           "一時置き場"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        font.bold:      true
                        color:          Theme.fg
                    }

                    Item { Layout.fillWidth: true }

                    // 削除ボタン（選択時のみ）
                    Rectangle {
                        visible:        FileDropState.selectedIndices.length > 0
                        implicitWidth:  _delLabel.implicitWidth + 18
                        implicitHeight: 26
                        radius:         Theme.radiusMd
                        color:          Qt.rgba(1, 0.2, 0.33, 0.85)

                        Text {
                            id:             _delLabel
                            anchors.centerIn: parent
                            text:           "削除 " + FileDropState.selectedIndices.length + " 件"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontXs
                            color:          "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    FileDropState.removeSelected()
                        }
                    }
                }

                // ── 空状態 ───────────────────────────────────
                Item {
                    Layout.fillWidth:  true
                    visible:           FileDropState.count === 0
                    implicitHeight:    64

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text:           "󰄼"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontXl
                            color:          Theme.fgDim
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text:           "バーにファイルをドロップ"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            color:          Theme.fgSub
                        }
                    }
                }

                // ── ファイルグリッド ─────────────────────────
                GridLayout {
                    Layout.fillWidth:  true
                    visible:           FileDropState.count > 0
                    columns:           3
                    columnSpacing:     8
                    rowSpacing:        8

                    Repeater {
                        model: FileDropState.files

                        delegate: Rectangle {
                            id: _card

                            readonly property string filePath: model.path
                            readonly property string fileName: model.name
                            readonly property int    fileIdx:  index

                            Layout.fillWidth:  true
                            implicitHeight:    80
                            radius:            Theme.radiusMd
                            color:             FileDropState.isSelected(index)
                                               ? Theme.bgPillBlue : Theme.bgLight
                            border.color:      FileDropState.isSelected(index)
                                               ? Theme.blue : "transparent"
                            border.width:      1

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            // ── ドラッグアウト ────────────────
                            Drag.active:   _dragH.active
                            Drag.dragType: Drag.Automatic
                            Drag.mimeData: ({ "text/uri-list": "file://" + _card.filePath + "\r\n" })
                            Drag.onDragFinished: action => {
                                if (action !== Qt.IgnoreAction)
                                    FileDropState.trashFile(_card.fileIdx)
                            }

                            DragHandler {
                                id: _dragH
                            }

                            ColumnLayout {
                                anchors { fill: parent; margins: 6 }
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text:           _fileIcon(_card.fileName)
                                    font.family:    Theme.iconFontFamily
                                    font.pixelSize: Theme.fontLg
                                    color:          Theme.blue
                                }

                                Text {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text:           _card.fileName
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.fontXs - 1
                                    color:          Theme.fg
                                    elide:          Text.ElideMiddle
                                }
                            }

                            MouseArea {
                                anchors.fill:  parent
                                onClicked:     FileDropState.toggleSelect(index)
                                onDoubleClicked: Qt.openUrlExternally("file://" + _card.filePath)
                            }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }

    function _fileIcon(name) {
        const ext = (name.split(".").pop() || "").toLowerCase()
        const map = ({
            "pdf": "󰈦", "png": "󰈟", "jpg": "󰈟", "jpeg": "󰈟",
            "gif": "󰈟", "svg": "󰈟", "webp": "󰈟",
            "mp4": "󰈰", "mkv": "󰈰", "mov": "󰈰", "avi": "󰈰",
            "mp3": "󰈣", "flac": "󰈣", "ogg": "󰈣", "wav": "󰈣",
            "zip": "󰛫", "tar": "󰛫", "gz": "󰛫", "xz": "󰛫", "7z": "󰛫", "rar": "󰛫",
            "txt": "󰈮", "md": "󰍔",
            "js": "󰌞", "ts": "󰌞", "py": "󰌞", "rs": "󰌞",
            "nix": "󰋊", "sh": "󰆍",
        })
        return map[ext] || " "
    }
}
