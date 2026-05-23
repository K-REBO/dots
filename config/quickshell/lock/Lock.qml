import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// ── ロック画面（hyprlock置き換え）──────────────────────────────
// qs ipc call lock activate  →  ロック
// 認証成功で自動解除

Item {
    id: lockRoot

    property bool locked: false

    // IPC トリガー
    IpcHandler {
        target: "lock"
        function activate(): void { lockRoot.locked = true }
    }

    WlSessionLock {
        id: sessionLock
        locked: lockRoot.locked

        // ロックサーフェス（全スクリーンに自動適用）
        WlSessionLockSurface {
            id: surf

            property string errMsg:   ""
            property bool   checking: false

            // エラー自動消去
            Timer {
                id: errClear; interval: 2500
                onTriggered: surf.errMsg = ""
            }

            // 認証関数
            function authenticate(pw) {
                if (surf.checking || pw === "") return
                surf.checking = true
                surf.errMsg   = ""
                pwField.clear()

                var p = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process { running: false }
                `, surf)

                p.command     = ["bash", "-c",
                    'printf "%s\\n" "$QS_LOCK_PASS" | ' +
                    'pamtester login "$USER" authenticate 2>/dev/null']
                p.environment = { "QS_LOCK_PASS": pw }
                p.onExited.connect(function(code) {
                    surf.checking = false
                    if (code === 0) {
                        sessionLock.locked = false
                        lockRoot.locked    = false
                    } else {
                        surf.errMsg = "認証に失敗しました"
                        errClear.restart()
                    }
                    p.destroy()
                })
                p.running = true
            }

            // ── UI ─────────────────────────────────────────────
            Rectangle {
                width:  surf.width
                height: surf.height
                color:  "#05050a"

                SystemClock { id: lClock; precision: SystemClock.Seconds }

                // フォーカス確保
                MouseArea {
                    anchors.fill: parent; z: -1
                    onClicked: pwField.forceActiveFocus()
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 28

                    // 時刻
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           Qt.formatTime(lClock.date, "HH:mm")
                        font.family:    Theme.fontFamily
                        font.pixelSize: 80
                        font.bold:      true
                        color:          Theme.fg
                    }

                    // 日付
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           Qt.formatDate(lClock.date, "dddd, MMMM d")
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontLg
                        color:          Theme.fgDark
                    }

                    // パスワードフィールド
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width:  320; height: 48
                        radius: Theme.radiusMd
                        color:  Theme.bgLight
                        border.color: surf.errMsg       ? Theme.red
                                    : pwField.activeFocus ? Theme.blue
                                    : Theme.border
                        border.width: 1.5
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        RowLayout {
                            anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                            spacing: 8

                            // スピナー
                            Text {
                                text:           surf.checking ? "󰔟" : ""
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontMd
                                color:          Theme.fgDark
                                RotationAnimation on rotation {
                                    running: surf.checking; loops: Animation.Infinite
                                    from: 0; to: 360; duration: 900
                                }
                            }

                            TextField {
                                id:               pwField
                                Layout.fillWidth: true
                                echoMode:         TextInput.Password
                                placeholderText:  surf.errMsg || "パスワードを入力..."
                                font.family:      Theme.fontFamily
                                font.pixelSize:   Theme.fontMd
                                color:            Theme.fg
                                background:       Item {}
                                placeholderTextColor: surf.errMsg ? Theme.red : Theme.fgDim
                                enabled:          !surf.checking

                                Keys.onReturnPressed: surf.authenticate(text)
                                Keys.onEscapePressed: clear()
                                Component.onCompleted: forceActiveFocus()
                            }
                        }
                    }

                    // エラーテキスト
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:        surf.errMsg !== ""
                        text:           surf.errMsg
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color:          Theme.red
                    }
                }
            }
        }
    }
}
