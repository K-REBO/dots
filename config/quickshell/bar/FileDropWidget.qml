import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    required property var screen

    anchors { top: true; left: true }
    margins {
        top:  Theme.barMargin
        left: screen ? Math.max(0, (screen.width - 400) / 2) : 0
    }

    implicitWidth:  400
    // ウィンドウ高さは固定最大値 — Wayland サーフェスリサイズ完全ゼロ
    // 視覚的な展開/収縮は _panelH → _widget.height のアニメーションが担う
    implicitHeight: Theme.barHeight + 12 + 460
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore
    aboveWindows:   true   // Bar (PanelWindow) の z-order より上に強制配置

    // ── 視覚高さアニメーション ────────────────────────────────────
    property real _panelH: Theme.barHeight
    Behavior on _panelH {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    Connections {
        target: FileDropState
        function onHoveredChanged() {
            root._panelH = FileDropState.hovered
                ? Theme.barHeight + 12 + Math.min(_gridCol.implicitHeight, 460)
                : Theme.barHeight
        }
        function onCountChanged() {
            if (FileDropState.hovered)
                root._panelH = Theme.barHeight + 12 + Math.min(_gridCol.implicitHeight, 460)
        }
    }

    // ── ドロップ受け取り（ウィンドウ全面）───────────────────────
    DropArea {
        id: _drop
        anchors.fill: parent
        onDropped: drop => {
            const urls = drop.urls
            for (let i = 0; i < urls.length; i++) {
                const url = urls[i].toString()
                if (url.startsWith("file://")) {
                    FileDropState.addFile(decodeURIComponent(url.slice(7)))
                }
            }
            drop.accept(Qt.CopyAction)
        }
    }

    // ── ホバー検知 (_panelH に追従する Item 内に限定) ────────────
    // ウィンドウが固定最大高さでも、アニメーション範囲外での誤発火を防ぐ
    Item {
        width:  parent.width
        height: root._panelH
        anchors.top: parent.top

        HoverHandler {
            onHoveredChanged: {
                if (hovered) FileDropState.startHover()
                else         FileDropState.endHover()
            }
        }
    }

    // ── 統合ウィジェット ─────────────────────────────────────────
    Rectangle {
        id: _widget

        readonly property real _vPad: (Theme.barHeight - Theme.pillH) / 2

        anchors {
            top:              parent.top
            topMargin:        _vPad
            horizontalCenter: parent.horizontalCenter
        }
        height: root._panelH - _vPad   // ウィンドウ高さとは独立してアニメーション

        // Nerd Font グリフの implicitWidth は Qt フォントメトリクスで 0 になる場合があるため
        // アイコン幅は fontMd 固定で計算する
        property real _pillCollapsedW: Theme.fontMd
                                       + (FileDropState.count > 0
                                          ? Theme.paddingXs + _badge.implicitWidth : 0)
                                       + 20

        property real _w: _pillCollapsedW
        Behavior on _w {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
        width:         _w
        implicitWidth: _w

        Connections {
            target: FileDropState
            function onHoveredChanged() {
                _widget._w = FileDropState.hovered ? 380 : _widget._pillCollapsedW
            }
        }

        radius:       Theme.radiusMd
        clip:         true
        color:        _drop.containsDrag
                      ? Qt.rgba(0.00, 0.83, 1.00, 0.12)
                      : Theme.bgLight
        border.color: (_drop.containsDrag || FileDropState.hovered) ? Theme.cyan : Theme.border
        border.width: 1
        Behavior on color        { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // ── Pill 行 ───────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                height: Theme.pillH

                // アイコンを左端固定にすることで、_expandArea アニメーションと
                // _w アニメーションが非同期でも centerIn による左オーバーフローを防ぐ
                RowLayout {
                    id: _pillRow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:           parent.left
                    anchors.leftMargin:     (Theme.pillH - Theme.fontMd) / 2  // = 10
                    spacing: Theme.paddingXs

                    Text {
                        id:             _iconText
                        text:           "󰉋"
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontMd
                        width:                    Theme.fontMd
                        horizontalAlignment:      Text.AlignHCenter
                        color:          _drop.containsDrag        ? Theme.cyan
                                      : FileDropState.count > 0  ? Theme.blue
                                      : Theme.fg
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    // Behavior を持たず _w の clip に委ねる
                    // → _expandArea と _w が非同期になるオーバーフロー問題を解消
                    Item {
                        id: _expandArea
                        height: Theme.pillH
                        implicitWidth: (FileDropState.hovered || _drop.containsDrag)
                                       ? _expandContent.implicitWidth + Theme.paddingXs : 0
                        clip: true

                        RowLayout {
                            id: _expandContent
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.paddingXs

                            Rectangle { width: 1; height: 16; color: Theme.border }

                            Text {
                                text:           _drop.containsDrag        ? "ここにドロップ"
                                              : FileDropState.count > 0  ? FileDropState.count + " 件"
                                              :                            "一時置き場"
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                color:          _drop.containsDrag        ? Theme.cyan
                                              : FileDropState.count > 0  ? Theme.blue
                                              :                            Theme.fgSub
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }
                        }
                    }

                    Rectangle {
                        id:             _badge
                        visible:        FileDropState.count > 0
                                        && !FileDropState.hovered
                                        && !_drop.containsDrag
                        implicitWidth:  _num.implicitWidth + 8
                        implicitHeight: 18
                        radius:         Theme.radiusFull
                        color:          Theme.blue

                        Text {
                            id:             _num
                            anchors.centerIn: parent
                            text:           FileDropState.count
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontXs - 2
                            color:          "#07070e"
                            font.bold:      true
                        }
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:  1
                color:   Theme.border
                opacity: FileDropState.hovered ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            // ── コンテンツ ────────────────────────────────────────
            ColumnLayout {
                id:       _gridCol
                Layout.fillWidth:   true
                Layout.leftMargin:  14
                Layout.rightMargin: 14
                spacing:  10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4

                    Text {
                        text:           "一時置き場"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        font.bold:      true
                        color:          Theme.fg
                    }

                    Item { Layout.fillWidth: true }

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

                Item {
                    Layout.fillWidth: true
                    visible:          FileDropState.count === 0
                    implicitHeight:   60

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
                            text:           "ここにファイルをドロップ"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            color:          Theme.fgSub
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    visible:          FileDropState.count > 0
                    columns:          3
                    columnSpacing:    8
                    rowSpacing:       8

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

                            Drag.active:   _dragH.active
                            Drag.dragType: Drag.Automatic
                            Drag.mimeData: ({ "text/uri-list": "file://" + _card.filePath + "\r\n" })
                            Drag.onDragFinished: action => {
                                if (action !== Qt.IgnoreAction)
                                    FileDropState.trashFile(_card.fileIdx)
                            }

                            DragHandler { id: _dragH }

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
                                    Layout.fillWidth:    true
                                    horizontalAlignment: Text.AlignHCenter
                                    text:                _card.fileName
                                    font.family:         Theme.fontFamily
                                    font.pixelSize:      Theme.fontXs - 1
                                    color:               Theme.fg
                                    elide:               Text.ElideMiddle
                                }
                            }

                            MouseArea {
                                anchors.fill:    parent
                                onClicked:       FileDropState.toggleSelect(index)
                                onDoubleClicked: Qt.openUrlExternally("file://" + _card.filePath)
                            }
                        }
                    }
                }

                Item { implicitHeight: 6 }
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
        return map[ext] || "󰈔"
    }
}
