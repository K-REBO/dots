{ config, pkgs, ... }:

{
  # eww (ElKowars wacky widgets)
  programs.eww.enable = true;

  # 設定ファイルをシンボリックリンク（nix store外の実パスを参照）
  home.file.".config/eww".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/config/eww";

  # 依存パッケージ
  home.packages = with pkgs; [
    jq                # JSON processing
    socat             # Hyprland IPC
    brightnessctl     # Brightness control
    playerctl         # Media player control
    bluez             # Bluetooth
    networkmanager    # WiFi (nmcli)
  ];
}
