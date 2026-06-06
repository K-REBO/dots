import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell

// ── GitHub Issues ウィジェット（pill + dropdown 一体型）──────────────
//
// TemplateWidget と同じ構造。Bar.qml の _ghSpacer が幅を確保し、
// PanelWindow がその右端に位置合わせされる。
PanelWindow {
    id: root
    required property var screen

    anchors { top: true; right: true }
    margins {
        top:   Theme.barMargin + (Theme.barHeight - Theme.pillH) / 2
        right: GithubIssuesState.marginRight > 0
               ? GithubIssuesState.marginRight
               : (Theme.barMargin + 14 + CalendarState.clockPillWidth + Theme.gap
                  + TemplateState.pillWidth + Theme.gap)
    }

    readonly property real _expandedW:  300
    readonly property real _collapsedW: Theme.fontMd + 20

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

    Binding { target: GithubIssuesState; property: "pillWidth"; value: _widget.width }

    // ── ウィジェット本体 ──────────────────────────────────────────
    Rectangle {
        id: _widget

        anchors { top: parent.top; right: parent.right }

        width: GithubIssuesState.open ? root._expandedW : root._collapsedW
        Behavior on width {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        height: GithubIssuesState.open
                ? (Theme.pillH + 1 + _dropContent.implicitHeight + 16)
                : Theme.pillH
        Behavior on height {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        clip:         true
        radius:       Theme.radiusMd
        color:        Theme.bgLight
        border.color: Theme.purple
        border.width: GithubIssuesState.open ? 1 : 0
        Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

        HoverHandler {
            onHoveredChanged: {
                GithubIssuesState.open = hovered
                if (hovered) GithubIssuesState.refresh()
            }
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

                    // 横展開エリア: issue 件数
                    Item {
                        implicitWidth:  GithubIssuesState.open ? _pillContent.implicitWidth : 0
                        implicitHeight: Theme.pillH
                        clip: true
                        Behavior on implicitWidth {
                            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                        }

                        RowLayout {
                            id:      _pillContent
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.paddingXs

                            Text {
                                text: GithubIssuesState.loading
                                      ? "..."
                                      : GithubIssuesState.issues.length + "件"
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                color:          Theme.fg
                                opacity:        GithubIssuesState.open ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                            }
                        }
                    }

                    // GitHub アイコン
                    Text {
                        text:           "󰊤"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontMd
                        color:          GithubIssuesState.open ? Theme.purple : Theme.fg
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }
            }

            // ── セパレーター ──────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:           1
                color:            Theme.border
                opacity:          GithubIssuesState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            // ── ドロップダウンコンテンツ ──────────────────────────
            ColumnLayout {
                id:                 _dropContent
                Layout.fillWidth:   true
                Layout.topMargin:   8
                Layout.leftMargin:  10
                Layout.rightMargin: 10
                spacing:            4
                opacity:            GithubIssuesState.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                // ロード中
                Text {
                    visible:          GithubIssuesState.loading && GithubIssuesState.issues.length === 0
                    text:             "読み込み中..."
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSm
                    color:            Theme.fgSub
                    Layout.fillWidth: true
                }

                // 空状態
                Text {
                    visible:          !GithubIssuesState.loading && GithubIssuesState.issues.length === 0
                    text:             "直近1週間のissueなし"
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSm
                    color:            Theme.fgSub
                    Layout.fillWidth: true
                }

                // Issue リスト
                Repeater {
                    model: GithubIssuesState.issues

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight:   46
                        radius:           Theme.radiusSm
                        color:            _rowHov.hovered ? Theme.bgHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        HoverHandler { id: _rowHov }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    Qt.openUrlExternally(modelData.url)
                        }

                        ColumnLayout {
                            anchors {
                                fill:         parent
                                leftMargin:   8
                                rightMargin:  8
                                topMargin:    5
                                bottomMargin: 5
                            }
                            spacing: 2

                            // リポジトリ + issue 番号 + 日付
                            RowLayout {
                                Layout.fillWidth: true
                                spacing:          6

                                Text {
                                    text:           "#" + modelData.number
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.fontXs
                                    color:          Theme.purple
                                    font.bold:      true
                                }

                                Text {
                                    text:             modelData.repo
                                    font.family:      Theme.fontFamily
                                    font.pixelSize:   Theme.fontXs
                                    color:            Theme.fgSub
                                    Layout.fillWidth: true
                                    elide:            Text.ElideRight
                                }

                                Text {
                                    text:           modelData.createdAt
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.fontXs
                                    color:          Theme.yellow
                                }
                            }

                            // タイトル
                            Text {
                                text:             modelData.title
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontSm
                                color:            Theme.fg
                                Layout.fillWidth: true
                                elide:            Text.ElideRight
                            }
                        }
                    }
                }

                Item { implicitHeight: 4 }
            }
        }
    }
}
