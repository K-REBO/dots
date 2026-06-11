import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    spacing: Theme.paddingXs

    // ── NyanCat スプライト(CPU負荷に応じて走行速度が変化) ───────────
    Item {
        Layout.preferredWidth:  Theme.pillH - 8
        Layout.preferredHeight: Theme.pillH - 8

        Image {
            id: _sprite
            anchors.fill: parent
            source:       "../assets/runcat/frame_" + String(RunCatService.frameIndex).padStart(3, "0") + ".png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true

            property bool _everReady: false
            onStatusChanged: if (status === Image.Ready) _everReady = true
        }

        // アセット未配置時のフォールバック表示
        Text {
            anchors.centerIn: parent
            visible:        !_sprite._everReady
            text:           "🐱"
            font.pixelSize: Theme.fontMd
        }
    }
}
