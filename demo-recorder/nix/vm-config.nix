{ pkgs, lib, modulesPath, ... }:

let
  # ===========================================================================
  # Replay Engine
  # ===========================================================================
  replayEngine = pkgs.writers.writePython3Bin "replay-engine"
    { flakeIgnore = [ "E265" "E302" "E303" "E501" "W503" ]; }
    (builtins.readFile ../scripts/replay-engine.py);

  # ===========================================================================
  # Demo Runner
  # ===========================================================================
  demoRunner = pkgs.writeShellScriptBin "demo-runner" ''
    set -euo pipefail
    DEMO_SCRIPT="''${DEMO_SCRIPT:-/shared/demo.json}"
    OUTPUT_FILE="''${OUTPUT_FILE:-/recordings/demo.mp4}"

    LOG=/recordings/demo-runner.log
    log() { echo "[demo-runner] $*" >> "$LOG" 2>/dev/null || true; }

    echo "[demo-runner] started" >> "$LOG" 2>/dev/null || true

    log "Waiting for Hyprland..."
    for i in $(seq 1 60); do
      hyprctl version &>/dev/null && break
      sleep 0.5
    done
    # eww + swaybg + wallpaper が起動するまで待機
    sleep 5

    # 9p 経由の書き込みは wf-recorder と相性が悪いため /tmp に録画してからコピー
    log "Starting wf-recorder -> /tmp/demo.mp4"
    wf-recorder --codec libx264 --framerate 15 -f /tmp/demo.mp4 &
    RECORDER_PID=$!
    sleep 0.5

    log "Running replay engine: $DEMO_SCRIPT"
    PYTHONUNBUFFERED=1 ${replayEngine}/bin/replay-engine "$DEMO_SCRIPT" \
      >> /recordings/replay-engine.log 2>&1 || true

    log "Stopping recorder..."
    kill -INT "$RECORDER_PID" || true
    for _i in $(seq 1 10); do
      kill -0 "$RECORDER_PID" 2>/dev/null || break
      sleep 0.5
    done
    kill -9 "$RECORDER_PID" 2>/dev/null || true

    cp /tmp/demo.mp4 "$OUTPUT_FILE"
    log "Saved: $OUTPUT_FILE"
    log "Shutting down."
    systemctl poweroff
  '';

  # ===========================================================================
  # wmfocus ラッパー (オプション込み)
  # ===========================================================================
  wmfocusDemo = pkgs.writeShellScriptBin "wmfocus-demo" ''
    exec ${pkgs.wmfocus}/bin/wmfocus \
      --textcolorcurrent lightseagreen \
      --font "UbuntuMono Nerd Font:120" \
      --offset 5,5 \
      --margin 0.1,0.2,0.2,0
  '';

  # ===========================================================================
  # Alacritty 設定 (実機と同一)
  # ===========================================================================
  alacrittyToml = pkgs.writeText "alacritty.toml" ''
    [window]
    opacity = 0.8
    decorations = "Full"
    title = "Alacritty"

    [window.dimensions]
    columns = 80
    lines = 24

    [cursor]
    blink_interval = 1300

    [cursor.style]
    shape = "Block"
    blinking = "On"

    [font]
    size = 18.0

    [font.normal]
    family = "UbuntuMono Nerd Font"
    style = "Regular"

    [font.bold]
    family = "UbuntuMono Nerd Font"
    style = "Bold"

    [font.italic]
    family = "UbuntuMono Nerd Font"
    style = "Italic"

    [font.bold_italic]
    family = "UbuntuMono Nerd Font"
    style = "Bold Italic"

    [colors.primary]
    foreground = "#d0cfcc"
    background = "#380C2A"
    bright_foreground = "#ffffff"

    [colors.normal]
    black   = "#171421"
    red     = "#c01c28"
    green   = "#26a269"
    yellow  = "#a2734c"
    blue    = "#12488b"
    magenta = "#a347ba"
    cyan    = "#2aa1b3"
    white   = "#d0cfcc"

    [colors.bright]
    black   = "#5e5c64"
    red     = "#f66151"
    green   = "#33d17a"
    yellow  = "#e9ad0c"
    blue    = "#2a7bde"
    magenta = "#c061cb"
    cyan    = "#33c7de"
    white   = "#ffffff"
  '';

  alacrittyConfigDir = pkgs.runCommand "alacritty-config-dir" {} ''
    mkdir -p $out
    cp ${alacrittyToml} $out/alacritty.toml
  '';

  # ===========================================================================
  # Eww 設定 (簡略版 - 実機の visual を再現)
  # ===========================================================================

  # スタティックスクリプト群
  ewwVolume = pkgs.writeShellScript "volume" ''
    case "$1" in
      icon)    echo "󰕾" ;;
      percent) echo "50" ;;
      *)       echo "󰕾" ;;
    esac
  '';

  ewwWifi = pkgs.writeShellScript "wifi" ''
    case "$1" in
      icon)    echo "󰤨" ;;
      ssid)    echo "Wi-Fi" ;;
      signal)  echo "80" ;;
      ip)      echo "192.168.1.1" ;;
      gateway) echo "192.168.1.1" ;;
    esac
  '';

  ewwBattery = pkgs.writeShellScript "battery" ''
    case "$1" in
      icon)    echo "󰂄" ;;
      percent) echo "85" ;;
      status)  echo "Charging" ;;
      time)    echo "1:30" ;;
    esac
  '';

  ewwBluetooth = pkgs.writeShellScript "bluetooth" ''
    case "$1" in
      icon)   echo "󰂯" ;;
      device) echo "" ;;
      *)      echo "󰂯" ;;
    esac
  '';

  ewwBrightness = pkgs.writeShellScript "brightness" ''
    case "$1" in
      percent) echo "60" ;;
      *)       echo "60" ;;
    esac
  '';

  # 簡略版 eww.yuck (taildrop / recorder / ime を除去)
  ewwYuck = pkgs.writeText "eww.yuck" ''
    ;; eww - demo VM (実機 visual 再現・簡略版)

    (defvar power-reveal false)
    (defvar volume-reveal false)

    ;; Power Menu
    (defwidget power []
      (eventbox :onhover "''${EWW_CMD} update power-reveal=true"
                :onhoverlost "''${EWW_CMD} update power-reveal=false"
        (box :class "power-menu" :space-evenly false :spacing 8
          (label :class "power-nixos" :text "󱄅")
          (revealer :transition "slideright" :reveal power-reveal :duration "300ms"
            (box :space-evenly false :spacing 6
              (label :class "power-separator" :text "|")
              (button :class "power-shutdown" :onclick "systemctl poweroff" :tooltip "Shutdown"
                (box :space-evenly false :spacing 4 (label :text "") (label :text "Shutdown")))
              (button :class "power-reboot" :onclick "systemctl reboot" :tooltip "Reboot"
                (box :space-evenly false :spacing 4 (label :text "") (label :text "Reboot")))
              (button :class "power-suspend" :onclick "systemctl suspend" :tooltip "Suspend"
                (box :space-evenly false :spacing 4 (label :text "󰒲") (label :text "Sleep")))
              (button :class "power-logout" :onclick "hyprctl dispatch exit" :tooltip "Logout"
                (box :space-evenly false :spacing 4 (label :text "󰍃") (label :text "Logout"))))))))

    ;; Workspaces (Hyprland 連携 - 実動作)
    (defwidget workspaces []
      (literal :content workspace))
    (deflisten workspace :initial "(box :class 'workspaces' '''')" "$HOME/.config/eww/scripts/workspace")

    ;; Volume (スタティック)
    (defwidget volume []
      (eventbox :onhover "''${EWW_CMD} update volume-reveal=true"
                :onhoverlost "''${EWW_CMD} update volume-reveal=false"
        (box :class "volume" :space-evenly false :spacing 4
          (revealer :transition "slideright" :reveal volume-reveal :duration "300ms"
            (scale :class "volume-slider"
                   :value volume-percent :min 0 :max 100
                   :onchange "echo"))
          (label :text volume-icon)
          (label :text "''${volume-percent}%"))))
    (defpoll volume-icon    :interval "999999s" "$HOME/.config/eww/scripts/volume icon")
    (defpoll volume-percent :interval "999999s" "$HOME/.config/eww/scripts/volume percent")

    ;; WiFi (スタティック)
    (defwidget wifi []
      (box :class "wifi" :space-evenly false :spacing 4
        (label :text wifi-icon)
        (label :text wifi-ssid)))
    (defpoll wifi-icon :interval "999999s" "$HOME/.config/eww/scripts/wifi icon")
    (defpoll wifi-ssid :interval "999999s" "$HOME/.config/eww/scripts/wifi ssid")

    ;; Bluetooth (スタティック)
    (defwidget bluetooth []
      (box :class "bluetooth" :space-evenly false :spacing 4
        (label :text bluetooth-icon)))
    (defpoll bluetooth-icon :interval "999999s" "$HOME/.config/eww/scripts/bluetooth icon")

    ;; Battery (スタティック)
    (defwidget battery []
      (box :class "battery ''${battery-status}" :space-evenly false :spacing 4
        (label :text battery-icon)
        (label :text "''${battery-percent}%")
        (label :class "battery-time" :text "(''${battery-time})")))
    (defpoll battery-icon    :interval "999999s" "$HOME/.config/eww/scripts/battery icon")
    (defpoll battery-percent :interval "999999s" "$HOME/.config/eww/scripts/battery percent")
    (defpoll battery-status  :interval "999999s" "$HOME/.config/eww/scripts/battery status")
    (defpoll battery-time    :interval "999999s" "$HOME/.config/eww/scripts/battery time")

    ;; Brightness (スタティック)
    (defwidget brightness []
      (box :class "brightness" :space-evenly false :spacing 4
        (label :text "󰃠")
        (label :text "''${brightness-percent}%")))
    (defpoll brightness-percent :interval "999999s" "$HOME/.config/eww/scripts/brightness percent")

    ;; DateTime (実動作)
    (defwidget datetime []
      (box :class "datetime" :space-evenly false :spacing 8
        (label :text "")
        (label :class "date" :text date-text)
        (label :class "time" :text time-text)))
    (defpoll date-text :interval "60s" "LC_TIME=C date '+%m/%d %a'")
    (defpoll time-text :interval "1s"  "date '+%H:%M'")

    ;; Bar Layout
    (defwidget left []
      (box :class "left" :space-evenly false :halign "start" :spacing 12
        (power)
        (workspaces)))

    (defwidget center []
      (box :class "center" :halign "center"))

    (defwidget right []
      (box :class "right" :space-evenly false :halign "end" :spacing 12
        (volume)
        (wifi)
        (bluetooth)
        (battery)
        (brightness)
        (datetime)))

    (defwidget bar []
      (centerbox :class "bar" :orientation "h"
        (left) (center) (right)))

    (defwindow bar
      :monitor 0
      :geometry (geometry :x "0" :y "0" :width "100%" :height "40px" :anchor "top center")
      :stacking "fg"
      :exclusive true
      :focusable false
      (bar))
  '';

  ewwConfigDir = pkgs.runCommand "eww-config-dir" {} ''
    mkdir -p $out/scripts
    cp ${ewwYuck} $out/eww.yuck
    cp ${../../config/eww/eww.scss} $out/eww.scss
    install -m 755 ${ewwVolume}     $out/scripts/volume
    install -m 755 ${ewwWifi}       $out/scripts/wifi
    install -m 755 ${ewwBattery}    $out/scripts/battery
    install -m 755 ${ewwBluetooth}  $out/scripts/bluetooth
    install -m 755 ${ewwBrightness} $out/scripts/brightness
    install -m 755 ${../../config/eww/scripts/workspace} $out/scripts/workspace
  '';

  # ===========================================================================
  # Vicinae 設定 (実機と同一)
  # ===========================================================================
  vicinaeConfigDir = pkgs.runCommand "vicinae-config-dir" {} ''
    mkdir -p $out
    cp ${../../config/vicinae/config.jsonc} $out/config.jsonc
    cp ${../../config/vicinae/settings.json} $out/settings.json
  '';

  # ===========================================================================
  # 壁紙
  # ===========================================================================
  wallpaper = ../../config/hypr/wallpapers/moshi_moshi_moshimo_saa.jpg;

  # ===========================================================================
  # Bash rc (nix run nixpkgs#neofetch ラッパー付き)
  # ===========================================================================
  # ===========================================================================
  # Starship 設定 (実機と同一内容)
  # ===========================================================================
  starshipToml = pkgs.writeText "starship.toml" ''
    add_newline = true
    format = "$directory$all\n"

    [aws]
    disabled = true

    [battery]
    charging_symbol = "⚡️"
    discharging_symbol = "💀"
    full_symbol = "🔋"

    [character]
    error_symbol = "[➜](bold red)"
    success_symbol = "[➜](bold green)"

    [cmd_duration]
    disabled = true

    [gcloud]
    disabled = true

    [git_branch]
    disabled = true

    [git_commit]
    disabled = true
  '';

  # ===========================================================================
  # Zsh rc (starship + nix run nixpkgs#neofetch ラッパー付き)
  # ===========================================================================
  zshRc = pkgs.writeText "demo-zshrc" ''
    # bracketed paste 無効化 (paste + \n でコマンド実行)
    unset zle_bracketed_paste

    # ホスト home-manager プロファイルの bin を PATH に追加
    # (ホストにインストール済みの CLI ツールが VM から自動利用可能になる)
    export PATH="/host-profile/bin:$PATH"

    # nix run nixpkgs#neofetch → fastfetch で代替 (neofetch は nixpkgs から削除済み)
    nix() {
      if [[ "$*" == "run nixpkgs#neofetch" ]]; then
        command fastfetch
      else
        command nix "$@"
      fi
    }

    # starship プロンプト
    eval "$(${pkgs.starship}/bin/starship init zsh)"
  '';

  # ===========================================================================
  # Zsh Profile (Hyprland 起動)
  # ===========================================================================
  zshProfile = pkgs.writeText "demo-zprofile" ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      export WLR_BACKENDS=headless
      export WLR_RENDERER=gles2
      export WLR_NO_HARDWARE_CURSORS=1
      export WLR_LIBINPUT_NO_DEVICES=1
      export LIBGL_ALWAYS_SOFTWARE=1
      export GALLIUM_DRIVER=llvmpipe
      export XDG_RUNTIME_DIR=/run/user/$(id -u)
      exec ${pkgs.hyprland}/bin/Hyprland -c ${hyprlandConf} \
        &>/recordings/hyprland.log
    fi
  '';

  # ===========================================================================
  # Hyprland 設定
  # 静的設定 (monitor/general/decoration/animations/misc/dwindle) は
  # ../wm/hyprland/hyprland.conf に外出し。
  # exec-once のみ Nix ストアパスを参照するためここで定義。
  # ===========================================================================
  hyprlandConf = pkgs.writeText "hyprland-demo.conf" ''
    source = ${../wm/hyprland/hyprland.conf}

    # 壁紙 + eww bar + vicinae daemon + demo runner
    exec-once = swaybg -i /home/demo/.config/hypr/wallpapers/moshi_moshimo_saa.jpg -m fill
    exec-once = eww open bar
    exec-once = vicinae server
    exec-once = ${demoRunner}/bin/demo-runner
  '';

in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  # ===========================================================================
  # VM 設定
  # ===========================================================================
  virtualisation = {
    memorySize              = 4096;
    diskSize                = 8192;
    graphics                = false;
    writableStoreUseTmpfs   = false;
    sharedDirectories = {
      recordings = {
        source        = "$HOME/vm-recordings";
        target        = "/recordings";
        securityModel = "none";
      };
      demo-scripts = {
        source        = "$DEMO_DIR";
        target        = "/shared";
        securityModel = "none";
      };
      # ホスト home-manager プロファイル (ホストの CLI ツールを VM から利用可能にする)
      host-profile = {
        source        = "$HOME/.local/state/nix/profiles/home-manager/home-path";
        target        = "/host-profile";
        securityModel = "none";
      };
    };
  };

  # ===========================================================================
  # システム基本設定
  # ===========================================================================
  system.stateVersion        = "24.11";
  nixpkgs.hostPlatform       = "x86_64-linux";
  boot.loader.grub.enable    = false;
  boot.kernelModules         = [ "uinput" ];
  networking.hostName        = "demo-vm";
  networking.useDHCP         = false;

  # alacritty の OpenGL (EGL) を llvmpipe ソフトウェアレンダリングで動作させる
  hardware.graphics.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="uinput", MODE="0660", GROUP="input"
  '';

  # ===========================================================================
  # フォント (alacritty: UbuntuMono NF, eww: JetBrainsMono NF)
  # ===========================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];

  # ===========================================================================
  # ユーザー & 自動ログイン
  # ===========================================================================
  users.users.demo = {
    isNormalUser = true;
    password     = "";
    extraGroups  = [ "video" "input" ];
    createHome   = true;
    home         = "/home/demo";
    shell        = pkgs.zsh;
  };

  programs.zsh.enable = true;

  services.getty.autologinUser = lib.mkForce "demo";

  # ===========================================================================
  # 設定ファイル配置
  # ===========================================================================
  systemd.tmpfiles.rules = [
    # ホームディレクトリ関連
    "C /home/demo/.zprofile 0644 demo users - ${zshProfile}"
    "C /home/demo/.zshrc    0644 demo users - ${zshRc}"

    # Alacritty
    "d  /home/demo/.config                           0755 demo users -"
    "L+ /home/demo/.config/alacritty - - - - ${alacrittyConfigDir}"

    # Eww
    "L+ /home/demo/.config/eww - - - - ${ewwConfigDir}"

    # Vicinae
    "L+ /home/demo/.config/vicinae - - - - ${vicinaeConfigDir}"

    # Starship
    "C /home/demo/.config/starship.toml 0644 demo users - ${starshipToml}"

    # 壁紙
    "d  /home/demo/.config/hypr              0755 demo users -"
    "d  /home/demo/.config/hypr/wallpapers   0755 demo users -"
    "C  /home/demo/.config/hypr/wallpapers/moshi_moshimo_saa.jpg 0644 demo users - ${wallpaper}"

    # 共有ディレクトリ
    "d /recordings 0777 demo users -"
    "d /shared     0755 demo users -"
  ];

  # ===========================================================================
  # Hyprland & パッケージ
  # ===========================================================================
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    # ターミナル・デスクトップアプリ (VM 固有設定が必要なもの)
    alacritty
    eww
    swaybg
    vicinae
    wmfocus
    fastfetch  # ホストプロファイルに含まれないため明示

    # Eww ワークスペーススクリプト依存
    jq
    socat

    # 録画・入力 (GIF変換はホスト側で実行)
    wf-recorder
    wtype
    wl-clipboard
    ydotool

    # フォント確認ツール
    fontconfig

    # リプレイ用
    replayEngine
    demoRunner
    wmfocusDemo

    # ユーティリティ
    bash
    zsh
    starship
    foot

    # ↑ fastfetch / pastel 等は /host-profile/bin 経由で自動利用可能
  ];

  security.polkit.enable = true;

  security.sudo.extraRules = [
    {
      users = [ "demo" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl poweroff";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
