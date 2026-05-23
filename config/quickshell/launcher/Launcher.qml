import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."
import Quickshell
import Quickshell.Io

// ── アプリランチャー（vicianeの置き換え）───────────────────────
// qs msg ipc call launcher.toggle でトグル
FloatingWindow {
    id: root
    visible:        false
    implicitWidth:  480
    implicitHeight: 520
    color:          "transparent"

    // 画面中央 (FloatingWindowはxcursor位置に出るため手動調整)
    screen: Quickshell.screens[0]

    // IPC: qs ipc call launcher toggle
    //      qs ipc call launcher open
    //      qs ipc call launcher close
    IpcHandler {
        target: "launcher"
        function toggle(): void { root.visible = !root.visible }
        function open():   void { root.visible = true; searchField.clear(); searchField.forceActiveFocus() }
        function close():  void { root.visible = false }
    }

    // ESCキー / フォーカス喪失で閉じる
    onVisibleChanged: if (visible) searchField.forceActiveFocus()

    Rectangle {
        anchors.fill:  parent
        radius:        Theme.radiusLg
        color:         Theme.bgDark
        border.color:  Theme.border
        border.width:  1

        // ── 検索フィールド ────────────────────────────────────
        Rectangle {
            id:            searchBar
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            height:        44
            radius:        Theme.radiusMd
            color:         Theme.bgLight
            border.color:  Theme.border
            border.width:  1

            RowLayout {
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                spacing: 8

                Text {
                    text:           ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                    color:          Theme.fgDark
                }

                TextField {
                    id:              searchField
                    Layout.fillWidth: true
                    placeholderText: "アプリを検索..."
                    font.family:     Theme.fontFamily
                    font.pixelSize:  Theme.fontMd
                    color:           Theme.fg
                    background:      Item {}
                    placeholderTextColor: Theme.fgDim

                    Keys.onEscapePressed: root.visible = false
                    Keys.onDownPressed:   appList.incrementCurrentIndex()
                    Keys.onUpPressed:     appList.decrementCurrentIndex()
                    Keys.onReturnPressed: appList.currentItem?.launch()
                    onTextChanged:        appModel.filter(text)
                }

                Text {
                    visible:        searchField.text !== ""
                    text:           "󰅖"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                    color:          Theme.fgDark
                    MouseArea {
                        anchors.fill: parent
                        onClicked:    searchField.clear()
                    }
                }
            }
        }

        // ── アプリ一覧 ────────────────────────────────────────
        ListView {
            id:     appList
            anchors {
                top:    searchBar.bottom
                left:   parent.left
                right:  parent.right
                bottom: parent.bottom
                topMargin:    8
                leftMargin:   8
                rightMargin:  8
                bottomMargin: 8
            }

            model:         appModel
            clip:          true
            spacing:       2
            keyNavigationEnabled: true

            delegate: Rectangle {
                id: appItem
                required property string name
                required property string exec
                required property string iconName
                required property int    index

                width:  appList.width
                height: 48
                radius: Theme.radiusMd
                color: {
                    if (appList.currentIndex === index) return Theme.bgHover
                    return hov.hovered ? Qt.rgba(1,1,1,0.04) : "transparent"
                }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                function launch() {
                    const cmd = appItem.exec
                        .replace(/%[uUfFdDnNickv]/g, "")
                        .trim()
                    launcher.command = ["bash", "-c", cmd + " &"]
                    launcher.running = true
                    root.visible = false
                    searchField.clear()
                }

                Process {
                    id: launcher
                    running: false
                }

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 12

                    Rectangle {
                        width: 28; height: 28; radius: 6
                        color: Qt.rgba(1,1,1,0.06)

                        Text {
                            anchors.centerIn: parent
                            text:           "󰘔"
                            font.family:    Theme.fontFamily
                            font.pixelSize: 16
                            color:          Theme.fgDark
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text:             appItem.name
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontMd
                        color:            Theme.fg
                        elide:            Text.ElideRight
                    }
                }

                HoverHandler { id: hov }
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    appItem.launch()
                }
            }
        }
    }

    // ── アプリモデル ──────────────────────────────────────────
    ListModel {
        id: appModel

        property var _allApps: []
        property string _query: ""

        function filter(query) {
            _query = query.toLowerCase()
            clear()
            for (const app of _allApps) {
                if (!_query || app.name.toLowerCase().includes(_query)) {
                    append(app)
                }
            }
        }

        function load(data) {
            _allApps = data
            filter(_query)
        }
    }

    // ── .desktop ファイルからアプリ一覧取得 ──────────────────
    Process {
        id: appLoader
        command: ["bash", "-c", `
            {
                find /run/current-system/sw/share/applications \
                     /home/bido/.local/share/applications \
                     /nix/var/nix/profiles/default/share/applications \
                     -name '*.desktop' 2>/dev/null
            } | sort -u | while read f; do
                name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
                exec=$(grep -m1 '^Exec=' "$f" | cut -d= -f2-)
                nodisp=$(grep -m1 '^NoDisplay=' "$f" | cut -d= -f2-)
                [ "$nodisp" = "true" ] && continue
                [ -z "$name" ] || [ -z "$exec" ] && continue
                echo "$name|$exec"
            done | sort -t'|' -k1 -f
        `]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const idx = line.indexOf("|")
                if (idx > 0) {
                    appModel._allApps.push({
                        name:     line.substring(0, idx),
                        exec:     line.substring(idx + 1),
                        iconName: ""
                    })
                }
            }
        }
        onExited: {
            appModel.load(appModel._allApps)
        }
    }
}
