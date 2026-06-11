pragma Singleton

import QtQuick

QtObject {
    id: root

    // ── アニメーションフレーム数(assets/runcat/ のフレーム枚数に合わせる) ──
    readonly property int frameCount: 26

    property int frameIndex: 0

    // ── 速度マッピング(ms) ───────────────────────────────────────
    readonly property int _minInterval: 1   // 負荷最大時(最速で走る)
    readonly property int _maxInterval: 60  // アイドル時(最遅、デフォルト速度)

    // 速度ソース(0.0-1.0)。将来 memory/network 等に切り替え可能にする想定。
    readonly property real activity: SystemStatsService.cpuPercent / 100

    readonly property int frameInterval:
        Math.round(_maxInterval - activity * (_maxInterval - _minInterval))

    property var _timer: Timer {
        interval: root.frameInterval
        running:  true
        repeat:   true
        onTriggered: root.frameIndex = (root.frameIndex + 1) % root.frameCount
    }
}
