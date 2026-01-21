# NixOS完全移行用システム設定
# このファイルはNixOSインストール後に /etc/nixos/configuration.nix として使用します

{ config, pkgs, ... }:

{
  imports = [
    # ハードウェア設定（nixos-generate-configで生成）
    ./hardware-configuration.nix
  ];

  # ====================
  # ブートローダー
  # ====================

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # カーネルパラメータ
    kernelParams = [
      # 必要に応じて追加
    ];

    # 最新カーネル（オプション）
    # kernelPackages = pkgs.linuxPackages_latest;
  };

  # ====================
  # ネットワーク設定
  # ====================

  networking = {
    hostName = "P16s";  # ホスト名を設定

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";  # iwdを使用（より高速）
    };

    # ファイアウォール
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # ====================
  # ロケール・タイムゾーン
  # ====================

  time.timeZone = "Asia/Tokyo";

  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    supportedLocales = [
      "ja_JP.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ====================
  # ユーザーアカウント
  # ====================

  users.users.bido = {
    isNormalUser = true;
    description = "Bido Nakamura";
    extraGroups = [
      "networkmanager"
      "wheel"          # sudo権限
      "audio"
      "video"
      "input"
      "docker"         # podmanでも使用
    ];
    shell = pkgs.fish;
  };

  # ====================
  # システムパッケージ
  # ====================

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    home-manager  # Home-Managerをシステムパッケージとして
    xremap        # キーリマッピングツール
  ];

  # ====================
  # プログラム設定
  # ====================

  programs = {
    fish.enable = true;
    hyprland.enable = true;  # Hyprlandをシステムレベルで有効化
  };

  # ====================
  # サービス
  # ====================

  services = {
    # Xサーバー（Hyprland用には不要だが、フォールバック用）
    xserver = {
      enable = true;
      xkb.layout = "us";

      # ディスプレイマネージャ（オプション）
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    # Pipewire（オーディオ）
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Bluetooth
    blueman.enable = true;

    # TLP（電源管理）
    tlp = {
      enable = true;
      settings = {
        # バッテリー充電閾値（ThinkPad）
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;

        # CPU設定
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # その他
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
      };
    };

    # その他のサービス
    upower.enable = true;           # 電源管理
    printing.enable = true;         # プリンタ（必要な場合）
    # openssh.enable = true;        # SSH（必要な場合）
  };

  # ====================
  # ハードウェア設定
  # ====================

  hardware = {
    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    # OpenGL/グラフィックス
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      # AMD GPU用パッケージ
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
    };

    # CPU microcode更新
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  # ====================
  # udev設定
  # ====================

  services.udev.extraRules = ''
    # xremap用: inputグループにinputデバイスへのアクセス権を付与
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"
  '';

  # ====================
  # セキュリティ
  # ====================

  security = {
    rtkit.enable = true;  # Pipewire用
    polkit.enable = true;
    sudo.wheelNeedsPassword = true;

    # xremapのために、inputグループのユーザーがinputデバイスにアクセス可能にする
    # polkitルール（オプション: xremapをsudoなしで使う場合）
  };

  # ====================
  # Nix設定
  # ====================

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;

      # 信頼されたユーザー
      trusted-users = [ "root" "bido" ];
    };

    # ガベージコレクション
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ====================
  # 仮想化・コンテナ
  # ====================

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;  # docker互換
      defaultNetwork.settings.dns_enabled = true;
    };

    # VirtualBox（必要な場合はコメント解除）
    # virtualbox.host.enable = true;
  };

  # ====================
  # フォント
  # ====================

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # 基本的なフォントはHome-Managerで管理
      # システムワイドで必要なものだけここに
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" "Noto Serif" ];
        sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
        monospace = [ "UbuntuMono Nerd Font" "JetBrains Mono" ];
      };
    };
  };

  # ====================
  # 環境変数
  # ====================

  environment.sessionVariables = {
    # Waylandサポート
    NIXOS_OZONE_WL = "1";  # Electron/Chromiumアプリ用

    # fcitx5
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # ====================
  # システム設定
  # ====================

  # システムの状態バージョン（変更しないこと）
  system.stateVersion = "24.11";  # NixOSインストール時のバージョンに合わせる

  # 自動アップグレード（オプション）
  # system.autoUpgrade = {
  #   enable = true;
  #   allowReboot = false;
  # };
}
