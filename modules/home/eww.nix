{ config, pkgs, ... }:

{
  # eww (ElKowars wacky widgets)
  programs.eww.enable = true;

  # 設定ファイルをシンボリックリンク（nix store外の実パスを参照）
  home.file.".config/eww".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/config/eww";

  # 依存パッケージ
  home.packages = with pkgs; [
    socat             # Hyprland IPC
    bluez             # Bluetooth
    networkmanager    # WiFi (nmcli)
    # jq, brightnessctl, playerctl は cli-tools.nix / hyprland.nix で定義済み
  ];
}
