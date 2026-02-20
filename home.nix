{ config, pkgs, ... }:

{
  # ユーザー情報
  home.username = "bido";
  home.homeDirectory = "/home/bido";

  # Home-Managerのバージョン（このままにしてください）
  home.stateVersion = "24.11";

  # Home-Managerに管理を任せる
  programs.home-manager.enable = true;

  # モジュールのインポート
  imports = [
    # Phase 1: CLIツール
    ./modules/home/cli-tools.nix
    ./modules/home/cowsay.nix
    ./modules/home/shell.nix
    ./modules/home/alacritty.nix
    ./modules/home/bash.nix
    ./modules/home/zsh.nix
    ./modules/home/git.nix
    ./modules/home/vim.nix

    # Phase 2A: 開発環境
    ./modules/home/vscode.nix
    ./modules/home/language-tools.nix

    # Phase 2B: WMツール
    ./modules/home/rofi.nix
    ./modules/home/wofi.nix
    ./modules/home/vicinae.nix

    # Phase 3: デスクトップ環境
    ./modules/home/hyprland.nix
    ./modules/home/niri.nix
    ./modules/home/fcitx5.nix
    ./modules/home/xremap.nix
    # ./modules/home/hyprpanel.nix  # ewwに移行のため無効化
    ./modules/home/eww.nix

    # Phase 4: システムサービス（ユーザーレベル）
    ./modules/home/pipewire.nix

    # Phase 5: 追加設定
    ./modules/home/fonts.nix
    ./modules/home/applications.nix
    ./modules/home/themes.nix
    ./modules/home/xdg.nix

    # WinApps
    ./modules/home/winapps.nix
  ];
}
