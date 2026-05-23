import QtQuick
import QtQuick.Layouts
import ".."
import "../services"
import Quickshell
import Quickshell.Hyprland

// ── フローティングバー ─────────────────────────────────────────
PanelWindow {
    id: root

    required property var screen

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.barMargin; right: Theme.barMargin }

    implicitHeight: Theme.barHeight
    color:          "transparent"
    exclusionMode:  ExclusionMode.Auto

    // 共有状態: 時計・カレンダー
    SystemClock { id: _sc; precision: SystemClock.Seconds }
    property bool calOpen: false

    // ── カレンダーポップアップ ────────────────────────────────────
    PanelWindow {
        id: calWin
        screen:         root.screen
        visible:        root.calOpen
        color:          "transparent"
        implicitWidth:  276
        implicitHeight: calCard.implicitHeight
        exclusionMode:  ExclusionMode.Ignore

        anchors { top: true; right: true }
        margins {
            top:   Theme.barMargin + Theme.barHeight + 6
            right: Theme.barMargin
        }

        Rectangle {
            id:     calCard
            width:  276
            radius: Theme.radiusMd
            color:  Theme.bgDark
            border.color: Qt.rgba(0.30, 0.60, 1.0, 0.25)
            border.width: 1
            implicitHeight: calCol.implicitHeight + 28

            Column {
                id:      calCol
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  Qt.formatTime(_sc.date, "HH:mm:ss")
                    font { family: Theme.fontFamily; pixelSize: 32; bold: true }
                    color: Theme.fg
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  Qt.formatDate(_sc.date, "dddd, MMMM d")
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                    color: Theme.fgSub
                }

                Rectangle { width: parent.width; height: 1; color: Theme.border }

                Row {
                    width: parent.width
                    Repeater {
                        model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                        Text {
                            width: 248 / 7
                            text:  modelData
                            horizontalAlignment: Text.AlignHCenter
                            font { family: Theme.fontFamily; pixelSize: Theme.fontXs }
                            color: index === 0 ? Theme.red : index === 6 ? Theme.blue : Theme.fgSub
                        }
                    }
                }

                Grid {
                    width:   parent.width
                    columns: 7
                    Repeater {
                        model: 42
                        delegate: Item {
                            id:     cell
                            width:  248 / 7
                            height: 26

                            property var d: {
                                const t  = _sc.date ?? new Date()
                                const f  = new Date(t.getFullYear(), t.getMonth(), 1)
                                const s  = new Date(f); s.setDate(1 - f.getDay())
                                const dd = new Date(s); dd.setDate(dd.getDate() + index)
                                return dd
                            }
                            property bool today: {
                                const t = _sc.date ?? new Date()
                                return d.getDate() === t.getDate()
                                    && d.getMonth() === t.getMonth()
                                    && d.getFullYear() === t.getFullYear()
                            }
                            property bool cur: d.getMonth() === (_sc.date ?? new Date()).getMonth()

                            Rectangle {
                                anchors.centerIn: parent
                                width: 24; height: 24; radius: Theme.radiusFull
                                color:        cell.today ? Qt.rgba(0.18, 0.42, 0.85, 0.25) : "transparent"
                                border.color: cell.today ? Theme.blue : "transparent"
                                border.width: 1
                            }
                            Text {
                                anchors.centerIn: parent
                                text:  cell.d.getDate()
                                font { family: Theme.fontFamily; pixelSize: Theme.fontXs; bold: cell.today }
                                color: cell.today ? Theme.blue
                                     : cell.cur   ? Theme.fg
                                     :              Theme.fgDim
                            }
                        }
                    }
                }
            }
        }

        MouseArea { anchors.fill: parent; z: -1; onClicked: root.calOpen = false }
    }

    // ── バー本体 ──────────────────────────────────────────────────
    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusMd
        color:         Theme.bgBar
        border.color:  Theme.border
        border.width:  1

        RowLayout {
            anchors {
                fill:         parent
                leftMargin:   10
                rightMargin:  10
                topMargin:    5
                bottomMargin: 5
            }
            spacing: Theme.gap

            // ── 左: NixOS + ワークスペース ───────────────────────────
            Rectangle {
                id:             _wsPill
                implicitHeight: parent.height
                implicitWidth:  _wsRow.implicitWidth + 22
                radius:         Theme.radiusFull
                color:          _wsHov.hovered ? Theme.bgPillCyanHov : Theme.bgPillCyan
                border.color:   Qt.rgba(0.00, 0.83, 1.00, 0.35)
                border.width:   1
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                HoverHandler { id: _wsHov }

                RowLayout {
                    id:              _wsRow
                    anchors.centerIn: parent
                    spacing:         8

                    Text {
                        text:           "󱄅"
                        font.family:    Theme.fontFamily
                        font.pixelSize: 15
                        color:          Theme.cyan
                    }
                    Text {
                        id:   _wsLabel
                        text: Hyprland.focusedMonitor?.activeWorkspace?.id ?? "1"
                        font { family: Theme.fontFamily; pixelSize: Theme.fontMd; bold: true }
                        color: Theme.cyan
                        Behavior on text {
                            SequentialAnimation {
                                NumberAnimation { target: _wsLabel; property: "opacity"; to: 0; duration: 60 }
                                NumberAnimation { target: _wsLabel; property: "opacity"; to: 1; duration: 100 }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onWheel: (e) => Hyprland.dispatch(e.angleDelta.y > 0 ? "workspace -1" : "workspace +1")
                }
            }

            // ── 中央: アクティブウィンドウ ───────────────────────────
            Item {
                Layout.fillWidth:  true
                Layout.fillHeight: true

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 7
                    visible: (Hyprland.activeToplevel?.title ?? "") !== ""

                    Text {
                        text: {
                            const id = Hyprland.activeToplevel?.wayland?.appId ?? ""
                            const map = {
                                firefox: "", chromium: "", brave: "",
                                alacritty: "", kitty: "", foot: "",
                                code: "󰨞", emacs: "", vim: "",
                                spotify: "", discord: "󰙯",
                                nautilus: "󰉓", dolphin: "󱔎",
                            }
                            const l = id.toLowerCase()
                            for (const [k, v] of Object.entries(map))
                                if (l.includes(k)) return v
                            return "󰘔"
                        }
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontMd
                        color:          Theme.fgSub
                    }
                    Text {
                        text:  Hyprland.activeToplevel?.title ?? ""
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                        color: Theme.fg
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        Layout.maximumWidth: 320
                        opacity: 0.85
                    }
                }
            }

            // ── 右: ウィジェット群 ────────────────────────────────────
            RowLayout {
                spacing: Theme.gap

                Recorder { }

                // ── 音量 ──────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _volRow.implicitWidth + 20
                    radius:         Theme.radiusFull
                    color:          _volHov.hovered ? Theme.bgPillHov : Theme.bgPill
                    border.color:   Theme.border
                    border.width:   1
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    HoverHandler { id: _volHov }

                    RowLayout {
                        id:              _volRow
                        anchors.centerIn: parent
                        spacing:         5

                        Text {
                            text:           AudioService.icon
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontMd
                            color:          AudioService.muted ? Theme.fgDim : Theme.fg
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }

                        Item {
                            implicitWidth:  _volHov.hovered ? _track.width + 6 : 0
                            implicitHeight: 20
                            clip:           true
                            Behavior on implicitWidth {
                                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                            }

                            Rectangle {
                                id:     _track
                                width:  64; height: 4; radius: 2
                                anchors.verticalCenter: parent.verticalCenter
                                color:  Qt.rgba(1, 1, 1, 0.12)

                                Rectangle {
                                    width:  (AudioService.volume / 100) * _track.width
                                    height: 4; radius: 2
                                    color:  AudioService.muted ? Theme.fgDim : Theme.cyan
                                    Behavior on width { NumberAnimation { duration: 60 } }
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: (m) =>
                                        AudioService.setVolume(Math.round(m.x / _track.width * 100))
                                    onWheel:  (w) =>
                                        AudioService.changeVolume(w.angleDelta.y > 0 ? 5 : -5)
                                }
                            }
                        }

                        Text {
                            text:  AudioService.volume + "%"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: AudioService.muted ? Theme.fgDim : Theme.fgSub
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked:    AudioService.toggleMute()
                        onWheel: (w) => AudioService.changeVolume(w.angleDelta.y > 0 ? 5 : -5)
                        propagateComposedEvents: true
                    }
                }

                // ── ネットワーク ＋ バッテリー ─────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _sysRow.implicitWidth + 20
                    radius:         Theme.radiusFull
                    color:          _sysHov.hovered ? Theme.bgPillHov : Theme.bgPill
                    border.color:   Theme.border
                    border.width:   1
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    HoverHandler { id: _sysHov }

                    RowLayout {
                        id:              _sysRow
                        anchors.centerIn: parent
                        spacing:         8

                        Text {
                            text:           NetworkService.icon
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontMd
                            color:          NetworkService.ssid ? Theme.green : Theme.fgDim
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }

                        Rectangle { width: 1; height: 12; color: Theme.border }

                        Text {
                            text:  BatteryService.icon + " " + BatteryService.percent + "%"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: {
                                if (BatteryService.status === "Charging") return Theme.green
                                if (BatteryService.percent <= 15)         return Theme.red
                                if (BatteryService.percent <= 35)         return Theme.yellow
                                return Theme.fgSub
                            }
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }
                }

                // ── 輝度 ＋ IME ───────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _imeRow.implicitWidth + 16
                    radius:         Theme.radiusFull
                    color:          _imeHov.hovered ? Theme.bgPillHov : Theme.bgPill
                    border.color:   Theme.border
                    border.width:   1
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    HoverHandler { id: _imeHov }

                    RowLayout {
                        id:              _imeRow
                        anchors.centerIn: parent
                        spacing:         8

                        Text {
                            text:  "󰃟 " + BrightnessService.percent + "%"
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm }
                            color: Theme.fgSub
                        }
                        Rectangle { width: 1; height: 12; color: Theme.border }
                        Text {
                            text:  ImeService.icon
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSm; bold: true }
                            color: ImeService.mode === "あ" ? Theme.blue : Theme.fgSub
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked:    ImeService.toggle()
                    }
                }

                // ── 時計 ────────────────────────────────────────────────
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth:  _clkRow.implicitWidth + 22
                    radius:         Theme.radiusFull
                    color:          _clkHov.hovered ? Theme.bgPillBlueHov : Theme.bgPillBlue
                    border.color:   Qt.rgba(0.30, 0.60, 1.00, 0.30)
                    border.width:   1
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    HoverHandler { id: _clkHov }

                    RowLayout {
                        id:              _clkRow
                        anchors.centerIn: parent
                        spacing:         7

                        Text {
                            text:  Qt.formatDate(_sc.date, "MM/dd")
                            font { family: Theme.fontFamily; pixelSize: Theme.fontXs }
                            color: Theme.fgSub
                        }
                        Rectangle { width: 1; height: 10; color: Qt.rgba(0.30, 0.60, 1.00, 0.35) }
                        Text {
                            text:  Qt.formatTime(_sc.date, "HH:mm")
                            font { family: Theme.fontFamily; pixelSize: Theme.fontLg; bold: true }
                            color: Theme.fg
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked:    root.calOpen = !root.calOpen
                    }
                }
            }
        }
    }
}
