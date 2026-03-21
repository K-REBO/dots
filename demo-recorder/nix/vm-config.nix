{ pkgs, lib, modulesPath, ... }:

let
  # リプレイエンジン (Python3スクリプト)
  replayEngine = pkgs.writers.writePython3Bin "replay-engine"
    { flakeIgnore = [ "E265" "E302" "E303" "W503" ]; }
    (builtins.readFile ../scripts/replay-engine.py);

  # VM内でHyprlandが起動後に自動実行されるランナー
  demoRunner = pkgs.writeShellScriptBin "demo-runner" ''
    set -euo pipefail
    DEMO_SCRIPT="''${DEMO_SCRIPT:-/shared/demo.json}"
    OUTPUT_FILE="''${OUTPUT_FILE:-/recordings/demo.mp4}"

    log() { echo "[demo-runner] $*" | tee -a /home/demo/demo-runner.log; }

    log "Waiting for Hyprland..."
    for i in $(seq 1 60); do
      hyprctl version &>/dev/null && break
      sleep 0.5
    done
    sleep 1

    log "Starting ydotoold..."
    ydotoold &
    YDOTOOL_PID=$!
    sleep 0.5

    log "Starting wf-recorder -> /tmp/demo.mp4"
    wf-recorder --codec libx264 --framerate 30 -f /tmp/demo.mp4 &
    RECORDER_PID=$!
    sleep 0.5

    log "Running replay engine: $DEMO_SCRIPT"
    ${replayEngine}/bin/replay-engine "$DEMO_SCRIPT" || true

    log "Stopping recorder..."
    kill "$RECORDER_PID" || true
    wait "$RECORDER_PID" 2>/dev/null || true

    mkdir -p "$(dirname "$OUTPUT_FILE")"
    cp /tmp/demo.mp4 "$OUTPUT_FILE"
    log "Saved: $OUTPUT_FILE"

    kill "$YDOTOOL_PID" 2>/dev/null || true
    log "Shutting down."
    systemctl poweroff
  '';

  # Hyprland 設定ファイル (Nixストアに配置)
  hyprlandConf = pkgs.writeText "hyprland-demo.conf" ''
    # Demo VM 用 Hyprland 設定 (最小構成)

    general {
      border_size = 2
      gaps_in = 4
      gaps_out = 8
    }

    decoration {
      rounding = 8
    }

    animations {
      enabled = false
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      vfr = false
    }

    # 仮想モニター (QEMU headless 環境)
    monitor = ,1920x1080@60,0x0,1

    # 起動後にデモランナーを実行
    exec-once = ${demoRunner}/bin/demo-runner
  '';

  # .bash_profile (WLR_* 環境変数を設定してから Hyprland を起動)
  bashProfile = pkgs.writeText "demo-bash-profile" ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      export WLR_BACKENDS=headless
      export WLR_RENDERER=pixman
      export WLR_NO_HARDWARE_CURSORS=1
      export WLR_LIBINPUT_NO_DEVICES=1
      export XDG_RUNTIME_DIR=/run/user/$(id -u)
      exec ${pkgs.hyprland}/bin/Hyprland -c ${hyprlandConf} \
        &>/home/demo/hyprland.log
    fi
  '';

in
{
  imports = [
    # nixpkgs 組み込みの QEMU VM サポート (system.build.vm を提供)
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  # ====================
  # VM 設定
  # ====================
  virtualisation = {
    memorySize = 4096;
    diskSize = 8192;
    graphics = false; # ヘッドレス (Waylandコンポジタが仮想出力を管理)
    writableStoreUseTmpfs = false;
    sharedDirectories = {
      # 録画出力先 (ホスト: ~/vm-recordings)
      recordings = {
        source = "$HOME/vm-recordings";
        target = "/recordings";
      };
      # デモスクリプト置き場 (ホスト: ./demo-recorder/demos)
      demo-scripts = {
        source = "$DEMO_DIR";
        target = "/shared";
      };
    };
  };

  # ====================
  # システム基本設定
  # ====================
  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.grub.enable = false;
  networking.hostName = "demo-vm";
  networking.useDHCP = false;

  # ====================
  # ユーザー & 自動ログイン
  # ====================
  users.users.demo = {
    isNormalUser = true;
    password = "";
    extraGroups = [ "video" "input" ];
    createHome = true;
    home = "/home/demo";
  };

  services.getty.autologinUser = lib.mkForce "demo";

  # systemd-tmpfiles で .bash_profile を Nixストアからコピー
  # (activation scripts より後に実行されるため home dir が確実に存在する)
  systemd.tmpfiles.rules = [
    "C /home/demo/.bash_profile 0644 demo users - ${bashProfile}"
    "d /recordings 0777 demo users -"
    "d /shared 0755 demo users -"
  ];

  # ====================
  # Hyprland & パッケージ
  # ====================
  programs.hyprland.enable = true;

  environment.systemPackages = [
    pkgs.wf-recorder
    pkgs.ydotool
    pkgs.kitty
    replayEngine
    demoRunner
  ];

  security.polkit.enable = true;

  # パスワード認証なしの sudo (シャットダウン用)
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
