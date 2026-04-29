{ config, pkgs, ... }:

{
  # eww (ElKowars wacky widgets)
  # programs.eww.enable = true だと zsh 統合(shell-completions)が自動追加されて遅いため手動管理

  # 設定ファイルをシンボリックリンク（nix store外の実パスを参照）
  home.file.".config/eww".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/config/eww";

  # 依存パッケージ
  home.packages = with pkgs; [
    eww               # ElKowars wacky widgets（programs.ewwは zsh 統合が遅いため手動）
    socat             # Hyprland IPC
    bluez             # Bluetooth
    networkmanager    # WiFi (nmcli)
    # jq, brightnessctl, playerctl は cli-tools.nix / hyprland.nix で定義済み
  ];
}
