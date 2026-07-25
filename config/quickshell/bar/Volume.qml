import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Widgets

// ── 音量ウィジェット（pill + dropdown 一体型）───────────────────
//
// Notifications と同じ構造・同じ展開方向。Volume は Bar 中間にあるため、
// pill の右端を固定基準にして dropdown を左へ展開する（右隣の WiFi 等の
// ウィジェットに重ならないようにするため）。Bar.qml の _volSpacer が幅を
// 確保し、PanelWindow がその右端に位置合わせされる。
PanelWindow {
    id: root
    required property var screen

    anchors { top: true; right: true }
    margins {
        top:   Theme.barMargin + (Theme.barHeight - Theme.pillH) / 2
        right: VolumeState.marginRight
    }

    readonly property real _collapsedW: _pillRow.implicitWidth + Theme.paddingMd * 2
    readonly property real _expandedW:  280

    implicitWidth:  _expandedW
    implicitHeight: Theme.pillH + 320
    color:          "transparent"
    exclusionMode:  ExclusionMode.Ignore

    mask: Region {
        x:      _widget.x
        y:      0
        width:  _widget.width
        height: _widget.height
    }

    // _widget.width をそのまま流すと、開閉アニメーションの中間値が毎フレーム
    // Bar.qml 側の _volSpacer.implicitWidth に伝わり、_rightRL.onWidthChanged
    // が連鎖して他の全 spacer(Notifications 含む)の位置再計算を誘発し、
    // Volume を開閉するだけで無関係な Notifications までカクつく原因になって
    // いた。アニメーションの目標値のみを反映し、中間フレームは伝播させない。
    Binding {
        target:   VolumeState
        property: "pillWidth"
        value:    VolumeState.open ? root._expandedW : root._collapsedW
    }

    // ── ウィジェット本体 ──────────────────────────────────────────
    Rectangle {
        id: _widget

        anchors { top: parent.top; right: parent.right }

        width: VolumeState.open ? root._expandedW : root._collapsedW
        Behavior on width {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        height: VolumeState.open
                ? (Theme.pillH + 1 + _dropContent.implicitHeight + 16)
                : Theme.pillH
        Behavior on height {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgLight
        border.color: Theme.green
        border.width: VolumeState.open ? 1 : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        HoverHandler {
            onHoveredChanged: VolumeState.open = hovered
        }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // ── ピル行（常時表示: アイコン + マスター音量%）───────
            Item {
                Layout.fillWidth: true
                implicitHeight:   Theme.pillH

                RowLayout {
                    id: _pillRow
                    // centerIn だとアイコンフォントのグリフ非対称性で見た目が
                    // 左右どちらかに寄って見えるため、左マージン基準で配置し
                    // _collapsedW 側も同じマージンで計算して対称にする。
                    anchors {
                        left:           parent.left
                        leftMargin:     Theme.paddingMd
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingXs

                    Text {
                        text:           AudioService.icon
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontMd
                        color:          Theme.green

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    AudioService.toggleMute()
                            onWheel: (w) => AudioService.changeVolume(w.angleDelta.y > 0 ? 5 : -5)
                        }
                    }

                    Text {
                        text:           AudioService.volume + "%"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.green
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
                opacity:          VolumeState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            // ── ドロップダウン ──────────────────────────────────────
            ColumnLayout {
                id:                 _dropContent
                Layout.fillWidth:   true
                Layout.topMargin:   8
                Layout.leftMargin:  10
                Layout.rightMargin: 10
                spacing:            10
                opacity:            VolumeState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                // ── システム全体 ─────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text:             "system"
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontSm
                        font.bold:        true
                        color:            Theme.fg
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.paddingXs

                        // マスタースライダー
                        Item {
                            Layout.fillWidth: true
                            implicitHeight:   20

                            Rectangle {
                                id: _masterTrack
                                anchors.verticalCenter: parent.verticalCenter
                                x: 2; width: parent.width - 4; height: 6; radius: 3
                                // bgHover はウィジェット背景(bgLight)とほぼ同じ暗さで
                                // コントラストがなく透過して見えるため、白ベースの
                                // bgPillHov で明確なトラックの帯として視認できるようにする。
                                color: Theme.bgPillHov

                                Rectangle {
                                    width:  Math.max(0, (AudioService.volume / 100) * _masterTrack.width)
                                    height: 6; radius: 3
                                    color:  AudioService.muted ? Theme.fgDim : Theme.green
                                    Behavior on width { NumberAnimation { duration: 60 } }
                                }

                                Rectangle {
                                    x:       Math.max(0, (AudioService.volume / 100) * _masterTrack.width) - 5
                                    y:       -3
                                    width:   10; height: 12; radius: 3
                                    color:   Theme.fg
                                    visible: _masterSliderArea.containsMouse || _masterSliderArea.pressed
                                }
                            }

                            MouseArea {
                                id: _masterSliderArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.SizeHorCursor

                                function apply(mx) {
                                    AudioService.setVolume(Math.round(
                                        Math.max(0, Math.min(100, (mx - 2) / Math.max(1, width - 4) * 100))))
                                }
                                onPressed:         (m) => apply(m.x)
                                onPositionChanged: (m) => { if (pressed) apply(m.x) }
                                onWheel: (w) => AudioService.changeVolume(w.angleDelta.y > 0 ? 5 : -5)
                            }
                        }

                        // パーセント
                        Text {
                            text:                AudioService.volume + "%"
                            font.family:         Theme.fontFamily
                            font.pixelSize:      Theme.fontXs
                            color:               Theme.fgDim
                            width:               28
                            horizontalAlignment: Text.AlignRight
                        }

                        // ミュートトグル（タップ領域を広めに確保）
                        Item {
                            implicitWidth:  24
                            implicitHeight: 24

                            Text {
                                anchors.centerIn: parent
                                text:           AudioService.muted ? "󰝟" : "󰕿"
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                color:          AudioService.muted ? Theme.fgDim : Theme.fgSub
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    AudioService.toggleMute()
                            }
                        }
                    }
                }

                // ── セパレーター ─────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height:           1
                    color:            Theme.border
                }

                // ── アプリ別音量 ─────────────────────────────────
                Text {
                    text:             "apps"
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSm
                    font.bold:        true
                    color:            Theme.fg
                    Layout.fillWidth: true
                }

                Text {
                    visible:          AudioService.streams.length === 0
                    text:             "再生中のアプリはありません"
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSm
                    color:            Theme.fgSub
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth:       true
                    Layout.preferredHeight: Math.min(_streamColumn.implicitHeight, 220)
                    visible:                AudioService.streams.length > 0

                    Flickable {
                        id: _streamFlick
                        anchors.fill:   parent
                        contentWidth:   width
                        contentHeight:  _streamColumn.implicitHeight
                        clip:           true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id:      _streamColumn
                            width:   _streamFlick.width
                            spacing: 6

                            Repeater {
                                model: AudioService.streams

                                delegate: RowLayout {
                                    id: _streamRow
                                    required property var modelData

                                    Layout.fillWidth: true
                                    spacing: Theme.paddingXs

                                    // アプリ名
                                    Text {
                                        text:                _streamRow.modelData.name
                                        font.family:         Theme.fontFamily
                                        font.pixelSize:      Theme.fontXs
                                        color:               _streamRow.modelData.muted ? Theme.fgDim : Theme.fg
                                        elide:               Text.ElideRight
                                        Layout.fillWidth:    true
                                        Layout.minimumWidth: 30
                                    }

                                    // 個別ミニスライダー
                                    Item {
                                        implicitWidth:  60
                                        implicitHeight: 20

                                        Rectangle {
                                            id: _streamTrack
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: 2; width: parent.width - 4; height: 6; radius: 3
                                            // bgHover はウィジェット背景(bgLight)とほぼ同じ暗さで
                                // コントラストがなく透過して見えるため、白ベースの
                                // bgPillHov で明確なトラックの帯として視認できるようにする。
                                color: Theme.bgPillHov

                                            Rectangle {
                                                width:  Math.max(0, (_streamRow.modelData.volume / 100) * _streamTrack.width)
                                                height: 6; radius: 3
                                                color:  _streamRow.modelData.muted ? Theme.fgDim : Theme.green
                                                Behavior on width { NumberAnimation { duration: 60 } }
                                            }

                                            Rectangle {
                                                x:       Math.max(0, (_streamRow.modelData.volume / 100) * _streamTrack.width) - 4
                                                y:       -2
                                                width:   8; height: 10; radius: 3
                                                color:   Theme.fg
                                                visible: _streamSliderArea.containsMouse || _streamSliderArea.pressed
                                            }
                                        }

                                        MouseArea {
                                            id: _streamSliderArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape:  Qt.SizeHorCursor

                                            function apply(mx) {
                                                AudioService.setStreamVolume(_streamRow.modelData.id, Math.round(
                                                    Math.max(0, Math.min(100, (mx - 2) / Math.max(1, width - 4) * 100))))
                                            }
                                            onPressed:         (m) => apply(m.x)
                                            onPositionChanged: (m) => { if (pressed) apply(m.x) }
                                            onWheel: (w) => AudioService.setStreamVolume(_streamRow.modelData.id,
                                                _streamRow.modelData.volume + (w.angleDelta.y > 0 ? 5 : -5))
                                        }
                                    }

                                    // パーセント
                                    Text {
                                        text:                _streamRow.modelData.volume + "%"
                                        font.family:         Theme.fontFamily
                                        font.pixelSize:      Theme.fontXs
                                        color:               Theme.fgDim
                                        width:               26
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    // ミュートトグル（タップ領域を広めに確保）
                                    Item {
                                        implicitWidth:  22
                                        implicitHeight: 22

                                        Text {
                                            anchors.centerIn: parent
                                            text:           _streamRow.modelData.muted ? "󰝟" : "󰕿"
                                            font.family:    Theme.fontFamily
                                            font.pixelSize: Theme.fontXs
                                            color:          _streamRow.modelData.muted ? Theme.fgDim : Theme.fgSub
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape:  Qt.PointingHandCursor
                                            onClicked:    AudioService.toggleStreamMute(_streamRow.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }
}
