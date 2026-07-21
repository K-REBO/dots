// notify-send 通知デーモン本体 + 通知ベルウィジェット用の状態管理 Singleton。
pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications

QtObject {
    id: root

    // ── ベルウィジェット UI状態 ──────────────────────────────────
    property bool open:        false
    property real pillWidth:   0
    property real marginRight: 0

    // ── おやすみモード（DND）────────────────────────────────────
    property bool doNotDisturb: false

    // ── 通知データ ────────────────────────────────────────────────
    // popups:  トースト表示中 [{ key, notification, appName, appIcon, summary, body, urgency, image, actions, timeout }]
    // history: 通知履歴（最新が先頭）[{ key, appName, appIcon, summary, body, urgency, image, time, read }]
    property var popups:  []
    property var history: []

    // key -> { notification, actions(QList<NotificationAction*>) }
    // ライブな QObject 参照は popups/history(var プロパティ) には載せず、
    // ここで個別に保持する。
    property var _live: ({})

    readonly property int unreadCount: history.filter(function(n) { return !n.read }).length

    property int _nextKey: 1
    readonly property int _maxHistory:     50
    readonly property int _defaultTimeout: 5000

    // ── notify-send 受信デーモン本体 ─────────────────────────────
    property NotificationServer server: NotificationServer {
        bodySupported:           true
        bodyMarkupSupported:     true
        bodyHyperlinksSupported: true
        actionsSupported:        true
        imageSupported:          true
        persistenceSupported:    true

        onNotification: notification => {
            notification.tracked = true

            const key = root._nextKey++

            let timeout
            if (notification.expireTimeout === 0) {
                timeout = 0 // 送信元が明示的に「自動消去なし」を指定
            } else if (notification.expireTimeout > 0) {
                timeout = notification.expireTimeout
            } else {
                // 未指定（-1）: Critical はユーザーが閉じるまで表示し続ける
                timeout = notification.urgency === NotificationUrgency.Critical
                          ? 0 : root._defaultTimeout
            }

            const appName = notification.appName || "通知"
            const appIcon = notification.appIcon || ""
            const summary = notification.summary || ""
            const body    = notification.body    || ""
            const urgency = notification.urgency
            const image   = notification.image   || ""

            // QList<NotificationAction*> をプレーン配列へコピーする
            // （シーケンス型を var プロパティや Repeater.model に直接渡さない）
            const liveActions  = []
            const actionLabels = []
            for (let i = 0; i < notification.actions.length; i++) {
                const a = notification.actions[i]
                liveActions.push(a)
                if (a.identifier !== "default") {
                    actionLabels.push({ identifier: a.identifier, text: a.text })
                }
            }
            root._live[key] = { notification: notification, actions: liveActions }

            const hist = root.history.slice()
            hist.unshift({
                key: key, appName: appName, appIcon: appIcon, summary: summary,
                body: body, urgency: urgency, image: image,
                time: Date.now(), read: false
            })
            if (hist.length > root._maxHistory) hist.length = root._maxHistory
            root.history = hist

            notification.closed.connect(function(reason) { root._removePopup(key) })

            if (!root.doNotDisturb) {
                root.popups = root.popups.concat([{
                    key: key, appName: appName, appIcon: appIcon, summary: summary,
                    body: body, urgency: urgency, image: image, actions: actionLabels, timeout: timeout
                }])
            } else {
                notification.tracked = false
            }
        }
    }

    // notification.tracked は受信時に一度 true にしたまま変更しない
    // （expire/dismiss が closed を再発火させ無限ループになるのを防ぐため）。
    function _removePopup(key) {
        delete root._live[key]
        root.popups = root.popups.filter(function(p) { return p.key !== key })
    }

    // タイムアウトによる自動消去
    function expirePopup(key) {
        const live = root._live[key]
        if (live) live.notification.expire()
        root._removePopup(key)
    }

    // ユーザー操作による消去
    function dismiss(key) {
        const live = root._live[key]
        if (live) live.notification.dismiss()
        root._removePopup(key)
    }

    function invokeAction(key, identifier) {
        const live = root._live[key]
        if (!live) return
        const action = live.actions.find(function(a) { return a.identifier === identifier })
        if (action) action.invoke()
        root.dismiss(key)
    }

    function markAllRead() {
        if (root.unreadCount === 0) return
        root.history = root.history.map(function(n) {
            return {
                key: n.key, appName: n.appName, appIcon: n.appIcon, summary: n.summary,
                body: n.body, urgency: n.urgency, image: n.image, time: n.time, read: true
            }
        })
    }

    function clearHistory() {
        for (const key in root._live) {
            root._live[key].notification.dismiss()
        }
        root._live   = {}
        root.popups  = []
        root.history = []
    }

    function relativeTime(ts) {
        const diff = Date.now() - ts
        if (diff < 60000)    return "たった今"
        if (diff < 3600000)  return Math.floor(diff / 60000) + "分前"
        if (diff < 86400000) return Math.floor(diff / 3600000) + "時間前"
        return Math.floor(diff / 86400000) + "日前"
    }

    // ── おやすみモードの永続化 ────────────────────────────────────
    readonly property string _dndCachePath: "$HOME/.cache/quickshell/notification_dnd"

    function toggleDnd() {
        root.doNotDisturb = !root.doNotDisturb
        root._saveDnd()
    }

    property Process _dndWriteProc: Process { running: false }
    function _saveDnd() {
        _dndWriteProc.command = ["bash", "-c",
            `mkdir -p "$HOME/.cache/quickshell" && echo "${root.doNotDisturb ? "1" : "0"}" > "${root._dndCachePath}"`]
        _dndWriteProc.running = true
    }

    property Process _dndReadProc: Process {
        command: ["bash", "-c", `cat "${root._dndCachePath}" 2>/dev/null`]
        running: false
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() === "1") root.doNotDisturb = true
            }
        }
    }

    Component.onCompleted: _dndReadProc.running = true
}
