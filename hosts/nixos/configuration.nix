{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/wshowkeys.nix
    ../../modules/nixos/thinkpad-p16s.nix
    ../../modules/nixos/winapps.nix
  ];

  # ====================
  # Secrets (agenix)
  # ====================
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets.wifi-jcom = {
    file = ../../secrets/wifi-password.age;
    path = "/etc/NetworkManager/system-connections/JCOM_RDGN.nmconnection";
    mode = "0600";
  };

  # ====================
  # Boot
  # ====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # linuxPackages_latest = 6.13 以降で rtw88_8821au がカーネル標準搭載
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NixOS の kmod ラッパー経由でロードすることで
  # systemd modprobe@.service の PATH 問題を回避
  boot.kernelModules = [ "configfs" "fuse" "efi_pstore" ];

  # 内蔵 Wi-Fi (ath11k_pci) は wmi_pci エラーで接続不可のため無効化
  # TP-LINK T2U nano (RTL8821AU) は rtw88_8821au (mainline) が自動ロード
  boot.blacklistedKernelModules = [ "ath11k_pci" ];

  # aarch64クロスビルド用（Raspberry Pi等）
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # ====================
  # Networking
  # ====================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      # Tailscale用設定
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      # SSH用ポート（Moshの初期接続に必須）
      allowedTCPPorts = [ 22 ];
      # Mosh用ポート（UDP 60000-61000）
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; }
      ];
    };
  };


  # ====================
  # Locale / Time
  # ====================
  time.timeZone = "Asia/Tokyo";

  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  environment.sessionVariables = {
    # GTK_IM_MODULE はWayland環境では設定しない（zwp_text_input_v3を使用するため）
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    # Wayland用設定
    NIXOS_OZONE_WL = "1";  # Electron/Chromiumアプリ用
    WLR_NO_HARDWARE_CURSORS = "1";  # 一部GPUでのカーソル問題回避
  };


  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # ====================
  # X / Display Manager
  # ====================
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  # ログインマネージャ（GDM）
  services.displayManager.gdm.enable = true;

  # ====================
  # Audio (PipeWire)
  # ====================
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;
    pulse.enable = true;
  };

  # ====================
  # User
  # ====================
  users.users.bido = {
    isNormalUser = true;
    description = "bido nakamura";
    extraGroups = [ "networkmanager" "wheel" "input" "kvm" ];
    shell = pkgs.zsh;
  };

  # ====================
  # Programs
  # ====================
  programs.zsh.enable = true;
  programs.firefox.enable = true;

  # AppImage サポート
  programs.appimage = {
    enable = true;
    binfmt = true;  # ./app.AppImage で直接実行可能にする
  };

  # nix-ld (動的リンクバイナリサポート)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
  ];


  # Hyprland - Wayland compositor
  programs.hyprland = {
    enable = true;
    withUWSM = true;  # 推奨: UWSMでSystemdと統合
    xwayland.enable = true;  # X11アプリ互換性
  };


  # XDG Desktop Portal (スクリーンシェア、ファイルピッカー等)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";  # 1.17以降の互換性設定
  };


  # ====================
  # Packages
  # ====================
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    psmisc  # killall, fuser, pstree等
    # Hyprland関連パッケージはHome Managerで管理

    # QEMU/KVM
    qemu_kvm          # qemu-system-x86_64 -enable-kvm
    OVMFFull          # UEFI ファームウェア（Windows 11 必須）
    swtpm             # ソフトウェア TPM 2.0（Windows 11 必須）
    virtio-win        # VirtIO ドライバー ISO

    # WinApps 依存
    freerdp           # xfreerdp バイナリ（RDP クライアント）
    dialog            # WinApps セットアップ TUI
    libnotify         # notify-send（WinApps 通知）

    # Network tools
    mosh              # モバイルシェル（SSHの代替）
    usbutils          # lsusb



    # deploy-rs: NixOS デプロイツール
    inputs.deploy-rs.packages.x86_64-linux.default
  ];

  # ====================
  # Services
  # ====================
  # Tailscale VPN
  services.tailscale.enable = true;

  # SSH Server（Mosh用に必須）
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;  # パスワード認証を禁止
      PermitRootLogin = "no";         # rootログインは禁止
    };
  };

  # 自動サスペンド設定
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";              # 蓋を閉じたらサスペンド
    HandleLidSwitchExternalPower = "ignore";  # AC接続時は蓋を閉じてもサスペンドしない
    HandlePowerKey = "poweroff";              # 電源ボタンでシャットダウン
  };

  services.printing.enable = true;

  services.blueman.enable = true;

  # TLP設定は modules/nixos/thinkpad-p16s.nix で管理

  services.upower.enable = true;

  # GVFS (Nautilus等のファイルマネージャ用)
  services.gvfs.enable = true;

  # ====================
  # Hardware
  # ====================
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # 新形式: hardware.graphics
    graphics = {
      enable = true;
      enable32Bit = false;
      #extraPackages = with pkgs; [
       # amdvlk
       # rocm-opencl-icd
       # rocm-opencl-runtime
      #];
    };

    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  # ====================
  # Fonts
  # ====================
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };

  # ====================
  # Nix
  # ====================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "bido" ];
      download-buffer-size = 524288000; # 500MB
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ====================
  # System
  # ====================

  # 時刻同期（サスペンド復帰後の時刻ずれを修正）
  # timesyncd はステップ補正が弱いため chrony に変更
  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    servers = [ "ntp.nict.jp" "0.jp.pool.ntp.org" "1.jp.pool.ntp.org" ];
    extraConfig = ''
      # 初回3回まで 1 秒超のズレはスラブではなくステップ補正（逆行防止）
      makestep 1.0 3
    '';
    # rtcsync は nixos-unstable の chrony モジュールが自動設定するため不要
  };

  # ====================
  # xremap用 udev設定
  # ====================                                                        
  services.udev.extraRules = ''                                                 
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput" 
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"            
  ''; 


  system.stateVersion = "25.11";
}
