{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/wshowkeys.nix
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


  boot.extraModprobeConfig = ''
    options 8821au rtw_power_mgnt=0 rtw_enusbss=0
  '';

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
    };
  };
  
  ## for wifi card TP-LINK T2U nano
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8821au
  ];
  # wpa_supplicant準備後に遅延ロード
  boot.blacklistedKernelModules = [ "8821au" ];
  systemd.services.rtl8821au-delayed = {
    description = "Delayed load RTL8821AU driver";
    after = [ "wpa_supplicant.service" ];
    wants = [ "wpa_supplicant.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/modprobe 8821au";
      RemainAfterExit = true;
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
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
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
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ====================
  # User
  # ====================
  users.users.bido = {
    isNormalUser = true;
    description = "bido nakamura";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.zsh;
  };

  # ====================
  # Programs
  # ====================
  programs.zsh.enable = true;
  programs.firefox.enable = true;


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


  # virtual box
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  users.extraGroups.vboxusers.members = [ "bido" ];


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
    # Hyprland関連パッケージはHome Managerで管理
  ];

  # ====================
  # Services
  # ====================
  services.printing.enable = true;

  services.blueman.enable = true;

#  services.tlp = {
#    enable = true;
#    settings = {
#      START_CHARGE_THRESH_BAT0 = 40;
#      STOP_CHARGE_THRESH_BAT0 = 80;
#      CPU_SCALING_GOVERNOR_ON_AC = "performance";
#      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
#      CPU_BOOST_ON_AC = 1;
#      CPU_BOOST_ON_BAT = 0;
#    };
#  };

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
      enable32Bit = true;
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
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ====================
  # System
  # ====================

  # ====================
  # xremap用 udev設定
  # ====================                                                        
  services.udev.extraRules = ''                                                 
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput" 
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"            
  ''; 


  system.stateVersion = "25.11";
}
