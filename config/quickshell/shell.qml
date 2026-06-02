// Quickshell シェル エントリーポイント
// Tokyo Night テーマ / Hyprland 向け
// Launcher → vicinae に戻し済み / Lock → hyprlock に戻し済み

import Quickshell
import "./bar"
import "./services"

ShellRoot {
    // ── バー（各スクリーンに1つ）───────────────────────────────
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }
}
