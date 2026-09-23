{ config, pkgs, lib, ... }:

let
  # Bitwigのキーファイルをページキャッシュに事前ロードし、
  # reboot後のコールドスタートを高速化する（低優先度で実行）
  bitwigWarmup = pkgs.writeShellScript "bitwig-warmup" ''
    renice -n 19 $$ > /dev/null 2>&1
    find ${pkgs.bitwig-studio}/libexec -maxdepth 4 \
      \( -name "*.jar" -o -name "BitwigStudio" -o -name "BitwigAudioEngine*" \) \
      -print0 | xargs -0 -P2 -I{} dd if={} of=/dev/null bs=4M status=none 2>/dev/null
  '';
in

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;  # NixOSモジュールのパッケージを使用
    # Hyprland 0.55以降hyprlang(.conf)形式は非推奨化され、数リリースで段階的に廃止予定のため
    # 新形式のLua設定(hyprland.lua)に移行する
    # https://hypr.land/news/26_lua/
    configType = "lua";

    # UWSM使用時はsystemd統合を無効化（必須）
    systemd.enable = false;
    xwayland.enable = true;

    # home-managerのsettings属性はhyprlang形式専用のため、
    # Lua設定は全てextraConfig（生のLuaソース）として記述する
    extraConfig = ''
      ------------------
      ---- MONITORS ----
      ------------------
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
      hl.monitor({ output = "eDP-1", mode = "2560x1600@60", position = "0x0", scale = "1" })

      -------------------
      ---- AUTOSTART ----
      -------------------
      hl.on("hyprland.start", function()
        -- Emacsデーモンはdefault.target起動時にWAYLAND_DISPLAYが未設定のため、
        -- Hyprland起動後に再起動してWayland環境を引き継がせる
        hl.exec_cmd("systemctl --user restart emacs.service")
        hl.exec_cmd("${pkgs.awww}/bin/awww-daemon")
        hl.exec_cmd("${pkgs.awww}/bin/awww img $HOME/.config/hypr/wallpapers/moshi_moshi_moshimo_saa.jpg")
        hl.exec_cmd("${pkgs.quickshell}/bin/quickshell")

        -- eww は quickshell に移行済み（復元時はコメントを外す）
        -- hl.exec_cmd("${config.programs.eww.package}/bin/eww open bar")

        hl.exec_cmd("${pkgs.hypridle}/bin/hypridle")
        hl.exec_cmd("${config.programs.wayland-fcitx5-indicator.package}/bin/wayland_fcitx5_indicator")
        -- reboot後のBitwig起動を高速化するためキーファイルをページキャッシュに読み込む
        hl.exec_cmd("${bitwigWarmup}")
      end)

      -------------------------------
      ---- ENVIRONMENT VARIABLES ----
      -------------------------------
      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")
      hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
      hl.env("QT_IM_MODULE", "fcitx")
      hl.env("XMODIFIERS", "@im=fcitx")
      hl.env("SDL_IM_MODULE", "fcitx")

      -----------------------
      ---- LOOK AND FEEL ----
      -----------------------
      hl.config({
        ecosystem = {
          no_update_news = true,
        },

        general = {
          gaps_in = 3,
          gaps_out = 2,
          border_size = 1,
          col = {
            active_border = "rgba(ff6600ee)",
            inactive_border = "rgba(595959aa)",
          },
          resize_on_border = false,
          allow_tearing = false,
          layout = "dwindle",
        },

        decoration = {
          rounding = 12,
          rounding_power = 2,
          active_opacity = 1.0,
          inactive_opacity = 1.0,
          shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
          },
          blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
          },
        },

        animations = {
          enabled = true,
        },

        dwindle = {
          preserve_split = true,
        },

        master = {
          new_status = "master",
        },

        misc = {
          force_default_wallpaper = 0,
          disable_hyprland_logo = true,
        },

        input = {
          kb_layout = "us",
          kb_rules = "evdev",
          follow_mouse = 1,
          sensitivity = 0,
          touchpad = {
            natural_scroll = false,
          },
        },
      })

      -- Default curves and animations
      hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
      hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
      hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
      hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0}  } })
      hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

      hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
      hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
      hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
      hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
      hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
      hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
      hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
      hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
      hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
      hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
      hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
      hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
      hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

      hl.workspace_rule({ workspace = "r[1-10]" })

      ---------------
      ---- INPUT ----
      ---------------
      hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

      ---------------------
      ---- KEYBINDINGS ----
      ---------------------
      local mainMod = "SUPER"

      -- 基本操作
      hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("${pkgs.alacritty}/bin/alacritty"))
      hl.bind(mainMod .. " + Q", hl.dsp.window.close())
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("${pkgs.kdePackages.dolphin}/bin/dolphin"))
      hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("${pkgs.vicinae}/bin/vicinae toggle"))
      hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("${pkgs.hyprlock}/bin/hyprlock"))
      -- フルスクリーン
      hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

      -- Emacs風フォーカス移動
      hl.bind(mainMod .. " + p", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + n", hl.dsp.focus({ direction = "down" }))
      hl.bind(mainMod .. " + f", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + b", hl.dsp.focus({ direction = "left" }))
      -- Emacs風ウィンドウ移動
      hl.bind(mainMod .. " + SHIFT + p", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mainMod .. " + SHIFT + n", hl.dsp.window.move({ direction = "down" }))
      hl.bind(mainMod .. " + SHIFT + f", hl.dsp.window.move({ direction = "right" }))
      hl.bind(mainMod .. " + SHIFT + b", hl.dsp.window.move({ direction = "left" }))
      -- 矢印キー
      hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

      -- ワークスペース切り替え / ウィンドウをワークスペースへ移動
      for i = 1, 10 do
        local key = i % 10 -- 10 は 0 キーに割り当て
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- スクラッチパッド
      hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
      hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
      -- マウスホイールでワークスペース
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

      -- スクリーンショット
      hl.bind("Print", hl.dsp.exec_cmd("${pkgs.grimblast}/bin/grimblast save area"))
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd("/home/bido/.config/hypr/scripts/toggle_recorder.sh"))

      -- hyprselect
      hl.bind(mainMod .. " + i", hl.dsp.exec_cmd("${pkgs.hyprselect}/bin/hyprselect --fill --bgcolor 'rgba(30,30,30,0.5)' --bgcolorcurrent 'rgba(48, 9, 11,0.6)' --textcolorcurrent lightseagreen --font 'UbuntuMono Nerd Font':200"))

      -- リサイズモード開始（ボーダーを赤くしてから resize サブマップへ）
      hl.bind(mainMod .. " + R", function()
        hl.config({ general = { col = { active_border = "rgba(ff0000ee)" }, border_size = 5 } })
        hl.dispatch(hl.dsp.submap("resize"))
      end)

      -- 音量/輝度（ロック画面でも動作 + 押下中リピート）
      hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl s 10%+"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl s 10%-"), { locked = true, repeating = true })

      -- メディアキー（ロック画面でも動作）
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && (wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo 1 || echo 0) > /sys/class/leds/platform::micmute/brightness 2>/dev/null || true"), { locked = true })
      hl.bind("XF86AudioNext",    hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl next"),       { locked = true })
      hl.bind("XF86AudioPause",   hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPrev",    hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl previous"),   { locked = true })

      -- マウスでのウィンドウ移動/リサイズ
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      --------------------------------
      ---- WINDOWS AND WORKSPACES ----
      --------------------------------
      hl.layer_rule({
        name  = "quickshell-notification-no-blur",
        match = { namespace = "^quickshell-notification$" },
        blur  = false,
      })

      hl.window_rule({
        name  = "suppress-maximize-events",
        match = { class = ".*" },
        suppress_event = "maximize",
      })

      hl.window_rule({
        name  = "bitwig-splash-pin",
        match = { class = "^show-splash-gtk$" },
        pin   = true,
        float = true,
      })

      hl.window_rule({
        name  = "nautilus-float",
        match = { class = "^org\\.gnome\\.Nautilus$" },
        float = true,
      })

      hl.window_rule({
        name   = "bitwig-file-dialog-center",
        match  = { class = "^Show-file-dialog-gtk3$" },
        float  = true,
        center = true,
      })

      hl.window_rule({
        name  = "fix-xwayland-drags",
        match = {
          class      = "^$",
          title      = "^$",
          xwayland   = true,
          float      = true,
          fullscreen = false,
          pin        = false,
        },
        no_focus = true,
      })

      -- リサイズサブマップ
      hl.define_submap("resize", function()
        hl.bind("b",     hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
        hl.bind("n",     hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })
        hl.bind("p",     hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
        hl.bind("f",     hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
        hl.bind("left",  hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
        hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
        hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
        hl.bind("right", hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })

        local function exitResize()
          hl.config({ general = { col = { active_border = "rgba(ff6600ee)" }, border_size = 1 } })
          hl.dispatch(hl.dsp.submap("reset"))
        end

        hl.bind("return", exitResize)
        hl.bind("escape", exitResize)
      end)
    '';
  };

  # Hyprland関連パッケージ
  home.packages = with pkgs; [
    hyprlock
    hypridle
    hyprpaper
    awww
    grimblast
    grim
    slurp
    satty
    wl-clipboard
    brightnessctl
    playerctl
    wireplumber
  ];

  # hypridle.conf は dpms-timeout スクリプトが動的に書き換えるため xdg.configFile 管理外にする。
  # home-manager switch のたびにシンボリックリンクが復元されると設定が失われるため、
  # activation でシンボリックリンクの場合のみデフォルト実ファイルへ差し替える。
  home.activation.hypridleConf = lib.hm.dag.entryAfter ["writeBoundary"] ''
    _hc="$HOME/.config/hypr/hypridle.conf"
    if [ ! -e "$_hc" ] || [ -L "$_hc" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$_hc")"
      $DRY_RUN_CMD cp --no-preserve=all ${../../config/hypr/hypridle.conf} "$_hc"
    fi
  '';

  xdg.configFile."hypr/hyprlock.conf".source = ../../config/hypr/hyprlock.conf;
  xdg.configFile."hypr/wallpapers".source = ../../config/hypr/wallpapers;
  xdg.configFile."hypr/scripts".source = ../../config/hypr/scripts;

  # xdg-desktop-portal-hyprland の起動改善
  # 問題: GDM greeter セッションで起動した後、ログイン時の Hyprland 切り替えで
  #       Wayland 接続が切断され SIGSEGV する（毎ブートの既知パターン）
  # 対策: HYPRLAND_INSTANCE_SIGNATURE がない環境では起動しない +
  #       クラッシュ後の回復タイミングを調整
  xdg.configFile."systemd/user/xdg-desktop-portal-hyprland.service.d/recovery.conf".text = ''
    [Unit]
    ConditionEnvironment=HYPRLAND_INSTANCE_SIGNATURE
    StartLimitIntervalSec=30
    StartLimitBurst=3

    [Service]
    RestartSec=2
  '';

}
