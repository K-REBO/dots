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
        left: screen ? Math.max(0, (screen.width - _maxW) / 2) : 0
    }

    // 最大幅: ファイルが多くても画面幅に収まるよう制限
    readonly property real _maxW: Math.min(screen ? screen.width - 40 : 600, 600)

    function fileUrl(path) {
        return "file://" + path.split("/").map(function(c) {
            return c ? encodeURIComponent(c) : c
        }).join("/")
    }

    // Wayland サーフェス固定: 見た目はアニメーションで調整
    implicitWidth:  _maxW
    implicitHeight: Theme.barHeight + 12 + 200
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore
    aboveWindows:   true

    // ── 視覚高さアニメーション ────────────────────────────────────
    property real _panelH: Theme.pillH
    Behavior on _panelH {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    Connections {
        target: FileDropState
        function onHoveredChanged() {
            root._panelH = FileDropState.hovered
                ? Theme.pillH + 1 + _popupContent.implicitHeight
                : Theme.pillH
        }
        function onCountChanged() {
            if (FileDropState.hovered) {
                const newH = Theme.pillH + 1 + _popupContent.implicitHeight
                if (newH > root._panelH)
                    root._panelH = newH
            }
        }
    }

    // ── ドロップ受け取り（ウィンドウ全面）───────────────────────
    DropArea {
        id: _drop
        anchors.fill: parent
        onContainsDragChanged: {
            if (containsDrag) FileDropState.startHover()
            else              FileDropState.endHover()
        }
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

    // ── メインウィジェット ────────────────────────────────────────
    Rectangle {
        id: _widget

        readonly property real _vPad: (Theme.barHeight - Theme.pillH) / 2

        anchors {
            top:              parent.top
            topMargin:        _vPad
            horizontalCenter: parent.horizontalCenter
        }
        height: root._panelH

        // 幅アニメーション: 閉時はピル幅、開時はポップアップ幅
        property real _pillW: Theme.fontMd
                              + (FileDropState.count > 0
                                 ? Theme.paddingXs + _badgeRef.implicitWidth : 0)
                              + 20
        property real _w: _pillW
        Behavior on _w {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
        width: _w

        Connections {
            target: FileDropState
            function onHoveredChanged() {
                _widget._w = FileDropState.hovered
                    ? Math.min(_popupContent.implicitWidth + 32, root._maxW)
                    : _widget._pillW
            }
            function onCountChanged() {
                if (!FileDropState.hovered) {
                    _widget._w = _widget._pillW
                } else {
                    const newW = Math.min(_popupContent.implicitWidth + 32, root._maxW)
                    if (newW > _widget._w)
                        _widget._w = newW  // ファイル追加時のみ拡張
                }
            }
        }

        // HoverHandler を _widget 本体に置く: 子アイテムにホバーしても hovered=true を維持
        HoverHandler {
            onHoveredChanged: {
                if (hovered) FileDropState.startHover()
                else         FileDropState.endHover()
            }
        }

        radius:       Theme.radiusMd
        clip:         true
        color:        _drop.containsDrag
                      ? Qt.rgba(0.04, 0.22, 0.30, 0.92)
                      : Theme.bgLight
        border.color: (_drop.containsDrag || FileDropState.hovered) ? Theme.cyan : Theme.border
        border.width: 1
        Behavior on color        { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // ── ピル行 ────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                height: Theme.pillH

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.paddingXs

                    Text {
                        text:           "󰈔"
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontMd
                        width:          Theme.fontMd
                        horizontalAlignment: Text.AlignHCenter
                        color: _drop.containsDrag        ? Theme.cyan
                             : FileDropState.count > 0  ? Theme.blue
                             : Theme.fg
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    // バッジ（閉時かつファイルあり）
                    Rectangle {
                        id:             _badgeRef
                        visible:        FileDropState.count > 0
                                        && !FileDropState.hovered
                                        && !_drop.containsDrag
                        implicitWidth:  _badgeNum.implicitWidth + 8
                        implicitHeight: 18
                        radius:         Theme.radiusFull
                        color:          Theme.blue

                        Text {
                            id:             _badgeNum
                            anchors.centerIn: parent
                            text:           FileDropState.count
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontXs - 2
                            color:          "#07070e"
                            font.bold:      true
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
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

            // ── ポップアップコンテンツ ────────────────────────────
            Item {
                id:                  _popupContent
                Layout.fillWidth:    true
                implicitWidth:       _popupLoader.item ? _popupLoader.item.implicitWidth  : 240
                implicitHeight:      _popupLoader.item ? _popupLoader.item.implicitHeight : 120
                clip:                true

                opacity: FileDropState.hovered ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                Loader {
                    id:    _popupLoader
                    width: parent.width

                    // ファイルなし → ドロップ誘導 UI
                    // ファイルあり → 横並びカードリスト
                    sourceComponent: FileDropState.count === 0 ? _dropHintComp : _fileListComp
                }
            }
        }
    }

    // ── ドロップ誘導コンポーネント ────────────────────────────────
    Component {
        id: _dropHintComp

        Item {
            implicitWidth:  240
            implicitHeight: _col.implicitHeight + 24

            ColumnLayout {
                id:       _col
                anchors { top: parent.top; topMargin: 12; horizontalCenter: parent.horizontalCenter }
                spacing:  10

                // inbox アイコン（大）
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text:           "󰈔"
                    font.family:    Theme.iconFontFamily
                    font.pixelSize: Theme.fontXl
                    color:          _drop.containsDrag ? Theme.cyan : Theme.fgSub
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }

                // "Drop" ヒント行
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.paddingXs

                    Text {
                        text:           "󰳽"
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.fgSub
                    }
                    Text {
                        text:           "Drop"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.fgSub
                    }

                    // ドラッグ中のファイル名プレビュー
                    RowLayout {
                        visible: _drop.containsDrag
                        spacing: 4

                        Text {
                            text:           "󰈔"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          Theme.cyan
                        }
                        Text {
                            text:           _drop.containsDrag ? "ファイル" : ""
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            color:          Theme.cyan
                        }
                    }
                }

                // 緑の "+" ボタン
                Rectangle {
                    Layout.alignment:  Qt.AlignHCenter
                    Layout.bottomMargin: 4
                    width:  36
                    height: 36
                    radius: 18
                    color:  Theme.green

                    Text {
                        anchors.centerIn: parent
                        text:           "+"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontLg
                        color:          Theme.bg
                        font.bold:      true
                    }
                }
            }
        }
    }

    // ── ファイルリストコンポーネント ──────────────────────────────
    Component {
        id: _fileListComp

        Item {
            implicitWidth:  _row.implicitWidth + 16
            implicitHeight: _row.implicitHeight + 20

            RowLayout {
                id:      _row
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 8 }
                spacing: 8

                // ── カードエリア（横スクロール可）────────────────
                Flickable {
                    id:           _flick
                    implicitWidth:  Math.min(_cardRow.implicitWidth, root._maxW - 100)
                    implicitHeight: _cardRow.implicitHeight
                    contentWidth:  _cardRow.implicitWidth
                    contentHeight: _cardRow.implicitHeight
                    clip:          true
                    flickableDirection: Flickable.HorizontalFlick

                    RowLayout {
                        id:      _cardRow
                        spacing: 8
                        width:   implicitWidth
                        height:  implicitHeight

                        Repeater {
                            model: FileDropState.files

                            delegate: Rectangle {
                                id: _card

                                readonly property string filePath: model.path
                                readonly property string fileName: model.name
                                readonly property int    fileIdx:  index
                                readonly property bool   isImage: {
                                    const ext = (fileName.split(".").pop() || "").toLowerCase()
                                    return ["png","jpg","jpeg","gif","webp","bmp","svg"].indexOf(ext) >= 0
                                }

                                implicitWidth:  90
                                implicitHeight: 100
                                radius:         Theme.radiusMd
                                color:          FileDropState.isSelected(index)
                                               ? Theme.bgPillBlue : Qt.rgba(0.10, 0.11, 0.20, 0.95)
                                border.color:   FileDropState.isSelected(index)
                                               ? Theme.blue : Theme.border
                                border.width:   1
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                Drag.active:   _dragH.active
                                Drag.dragType: Drag.Automatic
                                Drag.mimeData: ({ "text/uri-list": root.fileUrl(_card.filePath) + "\r\n" })
                                Drag.onDragFinished: action => {
                                    if (action !== Qt.IgnoreAction)
                                        FileDropState.trashFile(_card.fileIdx)
                                }

                                DragHandler { id: _dragH }

                                ColumnLayout {
                                    anchors { fill: parent; margins: 6 }
                                    spacing: 4

                                    // サムネイルエリア
                                    Rectangle {
                                        Layout.fillWidth:  true
                                        Layout.fillHeight: true
                                        color:             _card.isImage ? "transparent" : "#e8eaf6"
                                        radius:            4
                                        clip:              true

                                        // ① 画像サムネイル
                                        Image {
                                            visible:      _card.isImage && model.ready
                                            anchors.fill: parent
                                            source:       visible ? root.fileUrl(_card.filePath) : ""
                                            fillMode:     Image.PreserveAspectCrop
                                            smooth:       true
                                            asynchronous: true
                                            clip:         true
                                            sourceSize:   Qt.size(width, height)
                                        }

                                        // ② テキストプレビュー
                                        Text {
                                            visible:      !_card.isImage && model.preview !== ""
                                            anchors { fill: parent; margins: 3 }
                                            text:         model.preview
                                            font.family:  Theme.fontFamily
                                            font.pixelSize: 4
                                            wrapMode:     Text.Wrap
                                            color:        "#3a3d5c"
                                            clip:         true
                                        }

                                        // ③ 汎用デコレーション（フォールバック）
                                        ColumnLayout {
                                            visible:  !_card.isImage && model.preview === ""
                                            anchors { fill: parent; margins: 5 }
                                            spacing: 3

                                            Repeater {
                                                model: 5
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    height: 2
                                                    radius: 1
                                                    color:  index === 0 ? "#9096b8" : "#c5c8d8"
                                                }
                                            }
                                            Item { Layout.fillHeight: true }
                                        }
                                    }

                                    // ファイル名
                                    Text {
                                        Layout.fillWidth:    true
                                        horizontalAlignment: Text.AlignHCenter
                                        text:                _card.fileName
                                        font.family:         Theme.fontFamily
                                        font.pixelSize:      Theme.fontXs - 3
                                        color:               Theme.fg
                                        elide:               Text.ElideMiddle
                                    }
                                }

                                // 選択チェックマーク（左上）
                                Rectangle {
                                    visible: FileDropState.isSelected(index)
                                    anchors { top: parent.top; left: parent.left; margins: 4 }
                                    width:  18
                                    height: 18
                                    radius: 9
                                    color:  Theme.blue

                                    Text {
                                        anchors.centerIn: parent
                                        text:           "󰄬"
                                        font.family:    Theme.iconFontFamily
                                        font.pixelSize: 10
                                        color:          "#07070e"
                                    }
                                }

                                MouseArea {
                                    anchors.fill:    parent
                                    onClicked:       FileDropState.toggleSelect(index)
                                    onDoubleClicked: Qt.openUrlExternally(root.fileUrl(_card.filePath))
                                }
                            }
                        }
                    }
                }

                // ── アクションボタン ──────────────────────────────
                ColumnLayout {
                    spacing: 6

                    // ゴミ箱ボタン
                    Rectangle {
                        implicitWidth:  32
                        implicitHeight: 32
                        radius:         Theme.radiusMd
                        color:          _trashMouse.containsMouse
                                        ? Qt.rgba(1, 0.2, 0.33, 0.25)
                                        : Qt.rgba(1, 0.2, 0.33, 0.12)
                        border.color:   Qt.rgba(1, 0.2, 0.33, 0.4)
                        border.width:   1
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text:           "󰆴"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          Theme.red
                        }

                        MouseArea {
                            id:           _trashMouse
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked:    FileDropState.removeSelected()
                        }
                    }

                    // 折りたたみボタン（^）
                    Rectangle {
                        implicitWidth:  32
                        implicitHeight: 32
                        radius:         Theme.radiusMd
                        color:          _collapseMouse.containsMouse ? Theme.bgHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text:           ""
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          Theme.fgSub
                        }

                        MouseArea {
                            id:           _collapseMouse
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked:    FileDropState.endHover()
                        }
                    }
                }
            }
        }
    }
}
