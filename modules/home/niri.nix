{ config, pkgs, lib, ... }:

{
  # niri関連パッケージ
  # NixOSレベルで programs.niri.enable = true を設定済み
  home.packages = with pkgs; [
    # X11アプリ対応
    xwayland-satellite

    # niriで使えるユーティリティ（hyprland.nixと共通のものは省略）
    fuzzel  # niriと相性の良いランチャー

    # スクリーンロッカー（swaylockがniriで動作）
    swaylock
  ];

  # niri設定ファイル
  xdg.configFile."niri/config.kdl".text = ''
    // niri configuration
    // Hyprlandから移行した設定

    // ====================
    // Input (Hyprland input{} から移行)
    // ====================
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            // Hyprlandではnatural_scroll = false だった
            // natural-scroll
        }

        mouse {
            // sensitivity 0 (no modification)
        }

        // follow_mouse = 1 相当
        focus-follows-mouse max-scroll-amount="0%"
    }

    // ====================
    // Output / Monitor (Hyprland monitor= から移行)
    // ====================
    output "eDP-1" {
        mode "2560x1600@60"
        scale 1.0
        position x=0 y=0
    }

    // ====================
    // Layout (Hyprland general{}, decoration{} から移行)
    // ====================
    layout {
        // gaps_in = 2, gaps_out = 0 から移行
        gaps 2

        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        // border_size = 1, col.active_border, col.inactive_border から移行
        focus-ring {
            width 1
            active-color "#ff6600"    // Hyprland: rgba(ff6600ee)
            inactive-color "#595959"  // Hyprland: rgba(595959aa)
        }

        border {
            off
        }
    }

    // ====================
    // Cursor (Hyprland env = XCURSOR_* から移行)
    // ====================
    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    // ====================
    // Autostart (Hyprland exec-once から移行)
    // ====================
    // 壁紙
    spawn-at-startup "swww-daemon"
    spawn-at-startup "sh" "-c" "sleep 1 && swww img ~/.config/hypr/wallpapers/moshi_moshi_moshimo_saa.jpg"

    // fcitx5
    spawn-at-startup "fcitx5" "-d" "--replace"

    // ステータスバー (eww)
    spawn-at-startup "sh" "-c" "sleep 1 && eww open bar"

    // xremap
    spawn-at-startup "xremap" "~/.config/xremap/config.yaml"

    // X11アプリ対応
    spawn-at-startup "xwayland-satellite"

    // ====================
    // Environment (Hyprland env = から移行)
    // ====================
    environment {
        // GTK_IM_MODULE は Wayland では不要（text-input-v3 プロトコルを使用）
        // XWayland アプリ用には xwayland-satellite が DISPLAY を提供
        QT_IM_MODULE "fcitx"
        XMODIFIERS "@im=fcitx"
        SDL_IM_MODULE "fcitx"
        DISPLAY ":0"  // xwayland-satellite用
    }

    // ====================
    // Misc
    // ====================
    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    // ====================
    // Keybindings (Hyprland bind = から移行)
    // ====================
    binds {
        // ===== 基本操作 =====
        Mod+Return { spawn "alacritty"; }
        Mod+Q { close-window; }
        Mod+D { spawn "wofi" "-C" "~/.config/wofi/config"; }
        Mod+E { spawn "dolphin"; }
        Mod+L { spawn "swaylock"; }  // hyprlock → swaylock
        Mod+O { toggle-overview; }   // ワークスペース/ウィンドウ一覧
        Mod+Shift+E { quit; }
        Mod+Shift+Slash { show-hotkey-overlay; }

        // ===== フローティング切り替え =====
        // niriはスクロール式なのでフローティングの概念が異なる
        // Mod+Space { toggle-window-floating; }  // 未サポート

        // ===== Emacs風フォーカス移動 (pnfb) =====
        Mod+P { focus-window-up; }
        Mod+N { focus-window-down; }
        Mod+F { focus-column-right; }
        Mod+B { focus-column-left; }

        // ===== Emacs風ウィンドウ移動 (Shift+pnfb) =====
        Mod+Shift+P { move-window-up; }
        Mod+Shift+N { move-window-down; }
        Mod+Shift+F { move-column-right; }
        Mod+Shift+B { move-column-left; }

        // ===== 矢印キーでフォーカス移動 =====
        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }
        Mod+Right { focus-column-right; }

        // ===== 矢印キーでウィンドウ移動 =====
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Right { move-column-right; }

        // ===== ワークスペース切り替え (1-10) =====
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+0 { focus-workspace 10; }

        // ===== ウィンドウをワークスペースへ移動 =====
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }
        Mod+Shift+0 { move-column-to-workspace 10; }

        // ===== ワークスペーススクロール =====
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }
        Mod+Shift+Page_Up { move-column-to-workspace-up; }

        // マウスホイールでワークスペース切り替え
        Mod+WheelScrollDown { focus-workspace-down; }
        Mod+WheelScrollUp { focus-workspace-up; }

        // ===== カラム操作 (niri特有) =====
        Mod+BracketLeft { consume-window-into-column; }
        Mod+BracketRight { expel-window-from-column; }

        // ===== リサイズ・レイアウト =====
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+F { maximize-column; }
        Mod+Shift+Space { fullscreen-window; }
        Mod+C { center-column; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // ===== スクリーンショット =====
        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // ===== 音量 (Hyprland bindel から移行) =====
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        // ===== 輝度 =====
        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "s" "10%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "s" "10%-"; }

        // ===== メディアキー (Hyprland bindl から移行) =====
        XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
        XF86AudioPause allow-when-locked=true { spawn "playerctl" "play-pause"; }
        XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
        XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }

        // ===== マウス操作 =====
        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft { focus-column-left; }
    }

    // ====================
    // Window Rules (Hyprland windowrulev2 から移行)
    // ====================
    window-rule {
        // 全ウィンドウのmaximize要求を無視
        // suppressevent maximize 相当
        open-maximized false
    }
  '';
}
