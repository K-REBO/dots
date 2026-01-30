{ config, pkgs, ... }:

{
  services.polybar = {
    enable = true;
    package = pkgs.polybar;

    # カスタムスクリプトのパス
    script = "polybar main &";

    # 設定ファイル
    settings = {
      # カラー設定
      "colors" = {
        background = "#282A2E";
        background-alt = "#373B41";
        foreground = "#C5C8C6";
        primary = "#BE39AC";
        secondary = "#8ABEB7";
        alert = "#A54242";
        disabled = "#707880";
      };

      # メインバー
      "bar/main" = {
        bottom = false;
        width = "100%";
        height = "24pt";
        radius = 4;
        dpi = 96;

        background = "\${colors.background}";
        foreground = "\${colors.foreground}";

        line-size = "3pt";
        border-size = "2pt";
        border-color = "#00000000";

        padding-left = 0;
        padding-right = 1;
        module-margin = 1;

        separator = "|";
        separator-foreground = "\${colors.disabled}";

        font-0 = "JetBrainsMono Nerd Font Mono:size=16;4";
        font-1 = "Noto Sans CJK JP:style=Regular:size=10;3";

        modules-left = "xworkspaces workspace_apps";
        modules-right = "eth wlan memory cpu battery rest_battery redshift date";

        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
        enable-ipc = false;
      };

      # eDP用バー
      "bar/eDP" = {
        "inherit" = "bar/main";
        monitor = "eDP";
      };

      # HDMI用バー
      "bar/HDMI1" = {
        "inherit" = "bar/main";
        monitor = "HDMI-A-0";
      };

      # モジュール: xworkspaces
      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        label-active = "%name%";
        label-active-background = "\${colors.background-alt}";
        label-active-underline = "\${colors.primary}";
        label-active-padding = 1;
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-urgent = "%name%";
        label-urgent-background = "\${colors.alert}";
        label-urgent-padding = 1;
        label-empty = "%name%";
        label-empty-foreground = "\${colors.disabled}";
        label-empty-padding = 1;
      };

      # モジュール: workspace_apps (カスタムスクリプト)
      "module/workspace_apps" = {
        type = "custom/script";
        exec = "${config.home.homeDirectory}/.config/dots/polybar/scripts/workspace_apps.sh";
        interval = 3;
        format-prefix = " ";
        format-prefix-foreground = "\${colors.primary}";
      };

      # モジュール: memory
      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = "RAM ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage_used:2%%";
      };

      # モジュール: cpu
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = "CPU ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage:2%%";
      };

      # モジュール: battery
      "module/battery" = {
        type = "internal/battery";
        full-at = 100;
        battery = "BAT0";
        adapter = "AC";
        poll-interval = 5;
        format-charging = "<label-charging>";
        format-discharging = "<label-discharging>";
        label-charging = "Charging %percentage%%";
        label-discharging = "Discharging %percentage%%";
        label-full = "Fully charged";
        label-low = "BATTERY LOW";
      };

      # モジュール: rest_battery (カスタムスクリプト)
      "module/rest_battery" = {
        type = "custom/script";
        exec = "source ${config.home.homeDirectory}/.config/polybar/scripts/rest_battery_time.sh";
        interval = 5;
      };

      # ネットワーク基本設定
      "network-base" = {
        type = "internal/network";
        interval = 5;
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
        label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
      };

      # モジュール: wlan
      "module/wlan" = {
        "inherit" = "network-base";
        interface-type = "wireless";
        label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
      };

      # モジュール: eth
      "module/eth" = {
        "inherit" = "network-base";
        interface-type = "wired";
        label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
      };

      # モジュール: redshift (カスタムスクリプト)
      "module/redshift" = {
        type = "custom/script";
        format-prefix = " ";
        exec = "source ${config.home.homeDirectory}/.config/polybar/scripts/env.sh && ${config.home.homeDirectory}/.config/polybar/scripts/redshift.sh temperature";
        click-left = "source ${config.home.homeDirectory}/.config/polybar/scripts/env.sh && ${config.home.homeDirectory}/.config/polybar/scripts/redshift.sh toggle";
        scroll-up = "source ${config.home.homeDirectory}/.config/polybar/scripts/env.sh && ${config.home.homeDirectory}/.config/polybar/scripts/redshift.sh increase";
        scroll-down = "source ${config.home.homeDirectory}/.config/polybar/scripts/env.sh && ${config.home.homeDirectory}/.config/polybar/scripts/redshift.sh decrease";
        interval = "0.5";
      };

      # モジュール: date
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%Y-%m-%d(%a) %H:%M:%S";
        label = "%date%";
        label-foreground = "\${colors.primary}";
      };

      # 設定
      "settings" = {
        screenchange-reload = true;
        pseudo-transparency = true;
      };
    };
  };

  # 依存パッケージ
  home.packages = with pkgs; [
    # フォント
    jetbrains-mono
    noto-fonts-cjk-sans

    # polybar起動スクリプト用
    # 既存のスクリプトを使用
  ];

  # NOTE: カスタムスクリプトは既存の ~/.config/dots/polybar/scripts/ をそのまま使用
  # NixOS移行後は、スクリプトもNixで管理することを推奨
}
