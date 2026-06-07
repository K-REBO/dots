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

    // ── カレンダーポップアップ（各スクリーンに1つ）───────────────
    Variants {
        model: Quickshell.screens
        delegate: Calendar {
            required property var modelData
            screen: modelData
        }
    }

    // ── Battery ドロップダウン（各スクリーンに1つ）──────────────────
    Variants {
        model: Quickshell.screens
        delegate: BatteryDropdown {
            required property var modelData
            screen: modelData
        }
    }

    // ── SleepTime ドロップダウン（各スクリーンに1つ）────────────────
    Variants {
        model: Quickshell.screens
        delegate: SleepTimeDropdown {
            required property var modelData
            screen: modelData
        }
    }

    // ── FileDropウィジェット（各スクリーンに1つ）────────────────
    Variants {
        model: Quickshell.screens
        delegate: FileDropWidget {
            required property var modelData
            screen: modelData
        }
    }

    // ── GitHub Issues ウィジェット（各スクリーンに1つ）───────────
    Variants {
        model: Quickshell.screens
        delegate: GithubIssues {
            required property var modelData
            screen: modelData
        }
    }
}
