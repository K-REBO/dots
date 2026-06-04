import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    required property var screen

    // ── macOS Dark Mode palette ────────────────────────────────────
    readonly property color _bg:        Qt.rgba(0.11, 0.11, 0.12, 0.92)
    readonly property color _surface:   Qt.rgba(0.17, 0.17, 0.18, 0.96)
    readonly property color _border:    Qt.rgba(1, 1, 1, 0.10)
    readonly property color _borderAct: Qt.rgba(0.04, 0.51, 1.0, 0.55)
    readonly property color _dragBg:    Qt.rgba(0.04, 0.51, 1.0, 0.18)
    readonly property color _blue:      "#0A84FF"
    readonly property color _red:       "#FF453A"
    readonly property color _green:     "#30D158"
    readonly property color _yellow:    "#FFD60A"
    readonly property color _text:      Qt.rgba(1, 1, 1, 0.88)
    readonly property color _textSec:   Qt.rgba(1, 1, 1, 0.55)
    readonly property color _textTer:   Qt.rgba(1, 1, 1, 0.35)
    readonly property color _cardSelBg: Qt.rgba(0.04, 0.51, 1.0, 0.20)
    readonly property color _btnBluHov: Qt.rgba(0.04, 0.51, 1.0, 0.18)
    readonly property color _btnRedHov: Qt.rgba(1.0, 0.27, 0.23, 0.18)
    readonly property color _btnNeuHov: Qt.rgba(1, 1, 1, 0.10)
    readonly property real  _rWidget:   14
    readonly property real  _rCard:     10
    readonly property real  _rBtn:      8
    readonly property string _fontBody: "JetBrainsMono NFP"

    anchors { top: true; left: true }
    margins {
        top:  Theme.barMargin
        left: screen ? Math.max(0, (screen.width - _maxW) / 2) : 0
    }

    // 最大幅: ファイルが多くても画面幅に収まるよう制限
    readonly property real _maxW: Math.min(screen ? screen.width - 40 : 600, 600)

    // ── Taildrop 送信状態 ──────────────────────────────────────────
    property bool      _showPeers: false
    property bool      _sending:   false
    property string    _statusMsg: ""
    property ListModel _peers:     ListModel {}

    function _closePeers() { _showPeers = false; _statusMsg = "" }

    property Process _peerProc: Process {
        running: false
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split("|")
                if (p.length < 3) return
                root._peers.append({
                    online: p[0] === "1",
                    ip:     p[1].trim(),
                    name:   p[2].trim()
                })
            }
        }
    }

    function fileUrl(path) {
        return "file://" + path.split("/").map(function(c) {
            return c ? encodeURIComponent(c) : c
        }).join("/")
    }

    // ウィンドウサイズは固定（アニメーションなし）。mask で入力領域を可視ウィジェットに限定
    implicitWidth:  _maxW
    implicitHeight: Theme.barHeight + 12 + 200
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore
    aboveWindows:   true
    mask: Region {
        x:      _widget.x
        y:      _widget.y
        width:  _widget.width
        height: _widget.height
    }

    // ── 視覚高さアニメーション ────────────────────────────────────
    property real _panelH: Theme.pillH
    Behavior on _panelH {
        NumberAnimation { duration: 280; easing.type: Easing.OutExpo }
    }

    Connections {
        target: FileDropState
        function onHoveredChanged() {
            root._panelH = FileDropState.hovered
                ? Theme.pillH + 1 + _popupContent.implicitHeight
                : Theme.pillH
        }
    }

    Connections {
        target: _popupContent
        function onImplicitHeightChanged() {
            if (FileDropState.hovered)
                root._panelH = Theme.pillH + 1 + _popupContent.implicitHeight
        }
    }

    Connections {
        target: FileDropState
        function onCountChanged() {
            if (FileDropState.count === 0) root._closePeers()
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
            let hasExternal = false
            for (let i = 0; i < urls.length; i++) {
                const url = urls[i].toString()
                if (url.startsWith("file://")) {
                    const path = decodeURIComponent(url.slice(7))
                    // storage 以下は自分のカードからの自己ドロップ → 複製を防ぐためスキップ
                    if (FileDropState._dropBase && path.startsWith(FileDropState._dropBase + "/")) continue
                    FileDropState.addFile(path)
                    hasExternal = true
                }
            }
            if (hasExternal) drop.accept(Qt.CopyAction)
            // 自己ドロップは accept しない → Qt.IgnoreAction → trashFile 呼ばれない
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
            NumberAnimation { duration: 260; easing.type: Easing.OutExpo }
        }
        width: _w

        Connections {
            target: FileDropState
            function onHoveredChanged() {
                _widget._w = FileDropState.hovered
                    ? Math.min(_popupContent.implicitWidth + 32, root._maxW)
                    : _widget._pillW
            }
        }

        Connections {
            target: _popupContent
            function onImplicitWidthChanged() {
                if (FileDropState.hovered)
                    _widget._w = Math.min(_popupContent.implicitWidth + 32, root._maxW)
            }
        }

        // HoverHandler を _widget 本体に置く: 子アイテムにホバーしても hovered=true を維持
        HoverHandler {
            onHoveredChanged: {
                if (hovered) FileDropState.startHover()
                else         FileDropState.endHover()
            }
        }

        radius:       root._rWidget
        clip:         true
        color:        root._bg
        border.color: (_drop.containsDrag || FileDropState.hovered) ? root._borderAct : root._border
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
                        text:           " "
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontMd
                        width:          Theme.fontMd
                        horizontalAlignment: Text.AlignHCenter
                        color: (_drop.containsDrag || FileDropState.count > 0) ? root._blue : root._textTer
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
                        color:          root._blue

                        Text {
                            id:             _badgeNum
                            anchors.centerIn: parent
                            text:           FileDropState.count
                            font.family:    root._fontBody
                            font.pixelSize: Theme.fontXs - 2
                            color:          "#FFFFFF"
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
                color:   root._border
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
                    // ファイルあり + ピア選択中 → ピアピッカー
                    // ファイルあり → 横並びカードリスト
                    sourceComponent: FileDropState.count === 0 ? _dropHintComp
                                   : root._showPeers           ? _peerPickerComp
                                   :                             _fileListComp
                }
            }
        }
    }

    // ── ドロップ誘導コンポーネント ────────────────────────────────
    Component {
        id: _dropHintComp

        Item {
            implicitWidth:  260
            implicitHeight: 130

            // ドロップゾーン枠
            Rectangle {
                anchors { fill: parent; margins: 8 }
                radius: 10
                color:        _drop.containsDrag ? Qt.rgba(0.04, 0.51, 1.0, 0.06) : "transparent"
                border.width: 1
                border.color: _drop.containsDrag ? root._borderAct : Qt.rgba(1, 1, 1, 0.18)
                Behavior on color        { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8

                // トレイアイコン（大）
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text:           " "
                    font.family:    Theme.iconFontFamily
                    font.pixelSize: Theme.fontXl
                    color:          _drop.containsDrag ? root._blue : root._textTer
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }

                // ヒントテキスト
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text:           _drop.containsDrag ? "離してドロップ" : "ここにドロップ"
                    font.family:    root._fontBody
                    font.pixelSize: Theme.fontSm
                    color:          _drop.containsDrag ? root._blue : root._textSec
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
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

                // ── カードエリア ──────────────────────────────────
                RowLayout {
                    id:      _cardRow
                    spacing: 8

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
                                radius:         root._rCard
                                color:          FileDropState.isSelected(index)
                                               ? root._cardSelBg : root._surface
                                border.color:   FileDropState.isSelected(index)
                                               ? root._blue : root._border
                                border.width:   1
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                Drag.active:   _dragH.active
                                Drag.dragType: Drag.Automatic
                                Drag.mimeData: ({ "text/uri-list": root.fileUrl(_card.filePath) + "\r\n" })
                                Drag.onDragFinished: action => {
                                    if (action !== Qt.IgnoreAction)
                                        FileDropState.trashFile(_card.fileIdx)
                                }

                                DragHandler { id: _dragH; target: null }

                                ColumnLayout {
                                    anchors { fill: parent; margins: 6 }
                                    spacing: 4

                                    // サムネイルエリア
                                    Rectangle {
                                        Layout.fillWidth:  true
                                        Layout.fillHeight: true
                                        color:             _card.isImage ? "transparent" : Qt.rgba(0.28, 0.28, 0.30, 1.0)
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
                                            font.family:  root._fontBody
                                            font.pixelSize: 4
                                            wrapMode:     Text.Wrap
                                            color:        Qt.rgba(0.7, 0.7, 0.73, 0.85)
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
                                                    color:  index === 0 ? Qt.rgba(0.5, 0.5, 0.53, 0.9) : Qt.rgba(0.35, 0.35, 0.37, 0.7)
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
                                        font.family:         root._fontBody
                                        font.pixelSize:      Theme.fontXs - 3
                                        color:               root._text
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
                                    color:  root._blue

                                    Text {
                                        anchors.centerIn: parent
                                        text:           "󰄬"
                                        font.family:    Theme.iconFontFamily
                                        font.pixelSize: 10
                                        color:          "#FFFFFF"
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

                // ── アクションボタン ──────────────────────────────
                ColumnLayout {
                    spacing: 6

                    // Taildrop 送信ボタン
                    Rectangle {
                        implicitWidth:  32
                        implicitHeight: 32
                        radius:         root._rBtn
                        color:          _tailMouse.containsMouse ? root._btnBluHov : "transparent"
                        border.width:   0
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text:           "󰛶"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          root._blue
                        }

                        MouseArea {
                            id:           _tailMouse
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                root._peers.clear()
                                root._statusMsg = ""
                                root._peerProc.command = ["bash", "-c",
                                    "tailscale status --json 2>/dev/null | " +
                                    "python3 -c \"import json,sys; d=json.load(sys.stdin); " +
                                    "res=[('1' if p.get('Online',False) else '0'," +
                                    "p.get('TailscaleIPs',[''])[0]," +
                                    "(p.get('DNSName','').split('.')[0] or p.get('HostName','?'))) " +
                                    "for p in d.get('Peer',{}).values()]; " +
                                    "res.sort(reverse=True); [print(r[0]+'|'+r[1]+'|'+r[2]) for r in res]\""]
                                root._peerProc.running = true
                                root._showPeers = true
                            }
                        }
                    }

                    // ゴミ箱ボタン
                    Rectangle {
                        implicitWidth:  32
                        implicitHeight: 32
                        radius:         root._rBtn
                        color:          _trashMouse.containsMouse ? root._btnRedHov : "transparent"
                        border.width:   0
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text:           "󰆴"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          root._red
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
                        radius:         root._rBtn
                        color:          _collapseMouse.containsMouse ? root._btnNeuHov : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text:           ""
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          root._textSec
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

    // ── ピアピッカーコンポーネント ────────────────────────────────────────
    Component {
        id: _peerPickerComp

        Item {
            implicitWidth:  280
            implicitHeight: _pcol.implicitHeight + 20

            ColumnLayout {
                id:      _pcol
                anchors { top: parent.top; topMargin: 10
                          left: parent.left; leftMargin: 8
                          right: parent.right; rightMargin: 8 }
                spacing: 6

                // ── ヘッダー行 ────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    Rectangle {
                        implicitWidth:  28
                        implicitHeight: 28
                        radius:         root._rBtn
                        color:          _backMouse.containsMouse ? root._btnNeuHov : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text:           "󰁍"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontSm
                            color:          root._textSec
                        }

                        MouseArea {
                            id:           _backMouse
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked:    root._closePeers()
                        }
                    }

                    Text {
                        text:           "Taildropで送信"
                        font.family:    root._fontBody
                        font.pixelSize: Theme.fontSm
                        font.weight:    Font.Medium
                        color:          root._text
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: root._statusMsg !== ""
                                 || (root._sending && FileDropState.sendProgress !== "")
                        text:    (root._sending && FileDropState.sendProgress !== "")
                                 ? FileDropState.sendProgress
                                 : root._statusMsg
                        font.family: root._fontBody
                        font.pixelSize: Theme.fontXs - 2
                        font.weight: Font.Light
                        color: root._statusMsg.startsWith("失敗") ? root._red
                             : root._sending                     ? root._yellow
                             :                                     root._green
                        elide:              Text.ElideRight
                        Layout.maximumWidth: 200
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height:           1
                    color:            root._border
                }

                // フェッチ中インジケーター
                Item {
                    Layout.fillWidth: true
                    visible:          root._peerProc.running
                    implicitHeight:   40

                    Text {
                        anchors.centerIn: parent
                        text:           "󰔟"
                        font.family:    Theme.iconFontFamily
                        font.pixelSize: Theme.fontMd
                        color:          root._textTer
                    }
                }

                // ピアなし
                Item {
                    Layout.fillWidth: true
                    visible:          !root._peerProc.running && root._peers.count === 0
                    implicitHeight:   56

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text:           "󰤭"
                            font.family:    Theme.iconFontFamily
                            font.pixelSize: Theme.fontLg
                            color:          root._textTer
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text:           "オンラインのピアがいません"
                            font.family:    root._fontBody
                            font.pixelSize: Theme.fontXs
                            color:          root._textSec
                        }
                    }
                }

                // ── ピア一覧 ──────────────────────────────────────
                Repeater {
                    model: root._peers

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight:   36
                        radius:           root._rBtn
                        opacity:          model.online ? 1.0 : 0.4
                        color:            _peerMouse.containsMouse && !root._sending && model.online
                                          ? root._btnBluHov : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        RowLayout {
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                            spacing: 8

                            // オンライン状態ドット
                            Rectangle {
                                width:  8
                                height: 8
                                radius: 4
                                color:  model.online ? root._green : root._textTer
                            }

                            Text {
                                text:           "󰍹"
                                font.family:    Theme.iconFontFamily
                                font.pixelSize: Theme.fontSm
                                color:          model.online ? root._blue : root._textTer
                            }

                            Text {
                                text:           model.name
                                font.family:    root._fontBody
                                font.pixelSize: Theme.fontSm
                                color:          root._text
                                Layout.fillWidth: true
                                elide:          Text.ElideRight
                            }

                            Text {
                                text:           model.ip
                                font.family:    root._fontBody
                                font.pixelSize: Theme.fontXs - 2
                                color:          root._textSec
                            }
                        }

                        MouseArea {
                            id:           _peerMouse
                            anchors.fill: parent
                            cursorShape:  (!root._sending && model.online) ? Qt.PointingHandCursor : Qt.ArrowCursor
                            hoverEnabled: true
                            enabled:      !root._sending && model.online
                            onClicked: {
                                const sel   = FileDropState.selectedIndices
                                const paths = (sel && sel.length > 0)
                                    ? sel.map(i => FileDropState.files.get(i).path)
                                    : (function() {
                                        const all = []
                                        for (let j = 0; j < FileDropState.files.count; j++)
                                            all.push(FileDropState.files.get(j).path)
                                        return all
                                      })()

                                root._sending   = true
                                root._statusMsg = "送信中..."
                                FileDropState.sendViaTaildrop(model.ip, paths, function(ok, msg) {
                                    root._sending   = false
                                    root._statusMsg = ok ? "送信完了 ✓" : ("失敗: " + msg)
                                    if (ok) _doneTimer.restart()
                                })
                            }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }

            Timer {
                id:       _doneTimer
                interval: 3000
                onTriggered: root._closePeers()
            }
        }
    }
}
