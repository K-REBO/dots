// Quickshell シェル エントリーポイント
// Tokyo Night テーマ / Hyprland 向け

import Quickshell
import "./bar"
import "./launcher"
import "./lock"
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

    // ── アプリランチャー ─────────────────────────────────────────
    Launcher { }

    // ── ロック画面 ───────────────────────────────────────────────
    Lock { }
}
