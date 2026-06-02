import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell.Hyprland

// BarのscreenをpropertyとしてWorkspacesに渡す
RowLayout {
    id: root
    spacing: Theme.paddingXs

    property var barScreen: null

    // 対応モニターを特定する
    readonly property var monitor: {
        for (const m of Hyprland.monitors.values) {
            if (barScreen && m.name === barScreen.name) return m
        }
        return Hyprland.focusedMonitor
    }

    readonly property int activeWsId: monitor?.activeWorkspace?.id ?? -1

    Repeater {
        // id順にソート（QMLのObjectModelはソート不要でIDで配列取得）
        model: {
            const wsList = Hyprland.workspaces.values.slice()
            wsList.sort((a, b) => a.id - b.id)
            return wsList
        }

        delegate: WorkspaceButton {
            required property var modelData
            workspace: modelData
            isActive:  modelData.id === root.activeWsId
        }
    }
}
