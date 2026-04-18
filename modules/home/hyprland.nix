{ config, pkgs, lib, ... }:

let
  ocrPython = pkgs.python312.withPackages (ps: [ ps.manga-ocr ]);
  ocrDaemon = pkgs.writeText "ocr-daemon.py" ''
    import subprocess, tempfile, time, unicodedata, os
    from manga_ocr import MangaOcr

    mocr = MangaOcr()
    last_image = None

    while True:
        result = subprocess.run(
            ['${pkgs.wl-clipboard}/bin/wl-paste', '--type', 'image/png', '--no-newline'],
            capture_output=True
        )
        if result.returncode == 0 and result.stdout and result.stdout != last_image:
            last_image = result.stdout
            with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
                f.write(result.stdout)
                tmppath = f.name
            try:
                text = mocr(tmppath)
                text = unicodedata.normalize('NFKC', text)
                subprocess.run(['${pkgs.wl-clipboard}/bin/wl-copy'], input=text.encode(), check=True)
                subprocess.run(['${pkgs.libnotify}/bin/notify-send', 'OCR', text, '--expire-time=3000'])
            finally:
                os.unlink(tmppath)
        time.sleep(0.3)
  '';
  ocrScript = pkgs.writeShellScriptBin "ocr-screenshot" ''
    ${pkgs.grimblast}/bin/grimblast save area - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
  '';
in

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;  # NixOSモジュールのパッケージを使用

    # UWSM使用時はsystemd統合を無効化（必須）
    systemd.enable = false;
    xwayland.enable = true;

    settings = {
      monitor = [
        ",preferred,auto,auto"
        "eDP-1,2560x1600@60,0x0,1"
      ];

      "exec-once" = [
        "${pkgs.awww}/bin/awww-daemon"
        "${pkgs.awww}/bin/awww img $HOME/.config/hypr/wallpapers/moshi_moshi_moshimo_saa.jpg"
        "${config.programs.eww.package}/bin/eww open bar"
        "~/.config/eww/scripts/volume listen"
        "~/.config/eww/scripts/micmute sync"
        "~/.config/eww/scripts/wifi listen"
        "~/.config/eww/scripts/bluetooth listen"
        "~/.config/eww/scripts/battery listen"
        "~/.config/eww/scripts/ime listen"
        "${pkgs.xremap}/bin/xremap ~/.config/xremap/config.yaml"
        "${pkgs.vicinae}/bin/vicinae server"
        "${pkgs.hypridle}/bin/hypridle"
        "${config.programs.wayland-fcitx5-indicator.package}/bin/wayland_fcitx5_indicator"
        "${ocrPython}/bin/python3 ${ocrDaemon}"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
        "SDL_IM_MODULE,fcitx"
      ];

      "$mainMod" = "SUPER";

      general = {
        gaps_in = 3;
        gaps_out = 2;
        border_size = 1;
        "col.active_border" = "rgba(ff6600ee)";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = "yes, please :)";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      workspace = "r[1-10],";

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master.new_status = "master";

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "us";
        kb_rules = "evdev";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      bind = [
        # 基本操作
        "$mainMod, Return, exec, $HOME/.cargo/bin/alacritty"
        "$mainMod, Q, killactive,"
        "$mainMod, E, exec, ${pkgs.kdePackages.dolphin}/bin/dolphin"
        "$mainMod, space, togglefloating,"
        "$mainMod, D, exec, ${pkgs.vicinae}/bin/vicinae toggle"
        "$mainMod, J, togglesplit,"
        "$mainMod, L, exec, ${pkgs.hyprlock}/bin/hyprlock"
        # Emacs風フォーカス移動
        "$mainMod, p, movefocus, u"
        "$mainMod, n, movefocus, d"
        "$mainMod, f, movefocus, r"
        "$mainMod, b, movefocus, l"
        # Emacs風ウィンドウ移動
        "$mainMod SHIFT, p, movewindow, u"
        "$mainMod SHIFT, n, movewindow, d"
        "$mainMod SHIFT, f, movewindow, r"
        "$mainMod SHIFT, b, movewindow, l"
        # 矢印キー
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        # ワークスペース切り替え
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        # ウィンドウをワークスペースへ移動
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        # スクラッチパッド
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        # マウスホイールでワークスペース
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        # スクリーンショット
        ", Print, exec, ${pkgs.grimblast}/bin/grimblast save area"
        "SHIFT, Print, exec, /home/bido/.config/hypr/scripts/toggle_recorder.sh"
        # wmfocus
        ''$mainMod,i,exec,${pkgs.wmfocus}/bin/wmfocus --textcolorcurrent lightseagreen --font "UbuntuMono Nerd Font":120 --offset 5,5 --margin 0.1,0.2,0.2,0''
        # OCR screenshot
        "CTRL, Print, exec, ${ocrScript}/bin/ocr-screenshot"
        # リサイズモード開始
        ''$mainMod, R, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:col.active_border "rgba(ff0000ee)"''
        "$mainMod, R, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:border_size 5"
        "$mainMod, R, submap, resize"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%-"
      ];

      bindl = [
        ",XF86AudioMicMute, exec, $HOME/.config/eww/scripts/micmute"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };

    # submap は sequential state machine のため extraConfig に残す
    extraConfig = ''
      submap = resize
      binde = , b, resizeactive, -10 0
      binde = , n, resizeactive, 0 10
      binde = , p, resizeactive, 0 -10
      binde = , f, resizeactive, 10 0
      binde = , left, resizeactive, -20 0
      binde = , down, resizeactive, 0 20
      binde = , up, resizeactive, 0 -20
      binde = , right, resizeactive, 20 0
      bind = , return, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:col.active_border "rgba(ff6600ee)"
      bind = , return, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:border_size 1
      bind = , return, submap, reset
      bind = , escape, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:col.active_border "rgba(ff6600ee)"
      bind = , escape, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:border_size 1
      bind = , escape, submap, reset
      bind = $mainMod, R, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:col.active_border "rgba(ff6600ee)"
      bind = $mainMod, R, exec, ${pkgs.hyprland}/bin/hyprctl keyword general:border_size 1
      bind = $mainMod, R, submap, reset
      submap = reset
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
    ocrScript
    wl-clipboard
    brightnessctl
    playerctl
    wireplumber
    kdePackages.dolphin
    hyprpanel
  ];

  xdg.configFile."hypr/hypridle.conf".source = ../../config/hypr/hypridle.conf;
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

    [Service]
    RestartSec=2
    StartLimitIntervalSec=30
    StartLimitBurst=3
  '';

  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };
}
