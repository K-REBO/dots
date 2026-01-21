# NixOS完全移行時の参考設定
# このファイルは将来 /etc/nixos/configuration.nix に統合するための参考です
# 現在のArch Linux環境では使用しません

{ config, pkgs, ... }:

{
  # ====================
  # システムサービス設定
  # ====================

  # NetworkManager
  networking = {
    networkmanager = {
      enable = true;
      # WiFi backend
      wifi.backend = "iwd";  # または "wpa_supplicant"
    };

    # ホスト名
    hostName = "P16s";  # 現在のホスト名に合わせて変更

    # ファイアウォール
    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # TLP - 電源管理
  services.tlp = {
    enable = true;
    settings = {
      # バッテリー閾値（ThinkPad用）
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU設定
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # その他の設定はデフォルト値を使用
    };
  };

  # 電源管理（追加）
  services.upower.enable = true;
  powerManagement.enable = true;

  # ========================
  # オーディオ（システム側）
  # ========================

  # Pipewire（システムレベルで有効化）
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ===============
  # ハードウェア設定
  # ===============

  # AMD GPU
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  # ファームウェア
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  # ==================
  # ブートローダー設定
  # ==================

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # カーネルパラメータ
    kernelParams = [
      # AMD GPU用
      # 必要に応じて追加
    ];
  };

  # ===================
  # ユーザーアカウント
  # ===================

  users.users.bido = {
    isNormalUser = true;
    description = "Bido Nakamura";
    extraGroups = [
      "networkmanager"
      "wheel"          # sudo権限
      "audio"
      "video"
      "input"
      "docker"         # Dockerを使用する場合
    ];
    shell = pkgs.fish;
  };

  # ==============
  # システム設定
  # ==============

  # タイムゾーン
  time.timeZone = "Asia/Tokyo";

  # ロケール
  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    supportedLocales = [
      "ja_JP.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  # コンソール
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ======================
  # システムパッケージ
  # ======================

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    # その他必要なシステムツール
  ];

  # =================
  # サービス有効化
  # =================

  services = {
    # ログイン画面
    # GDMまたはSDDM
    # xserver.displayManager.gdm.enable = true;

    # SSH（必要な場合）
    # openssh.enable = true;

    # Printing（プリンタ使用時）
    # printing.enable = true;
  };

  # ================
  # Nix設定
  # ================

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ===================
  # NixOSバージョン
  # ===================

  # このファイルはNixOS 24.11を想定
  system.stateVersion = "24.11";
}
