pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property var profiles: ["performance", "balanced", "low-power"]
    property int    profileIndex:   1
    property string currentProfile: "balanced"

    property var _fetch: Process {
        command: ["bash", "-c", "cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo balanced"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim()
                const idx = root.profiles.indexOf(p)
                root.profileIndex   = idx >= 0 ? idx : 1
                root.currentProfile = root.profiles[root.profileIndex]
                root._fetch.running = false
            }
        }
    }

    function refresh() { _fetch.running = true }

    function cycleProfile() {
        const next = (profileIndex + 1) % profiles.length
        _set.command = ["bash", "-c",
            "echo '" + profiles[next] + "' > /sys/firmware/acpi/platform_profile"]
        _set.running = true
    }

    property var _set: Process {
        running: false
        onExited: root.refresh()
    }

    property var _timer: Timer {
        interval: 5000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
