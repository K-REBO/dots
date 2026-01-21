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
    ./modules/cli-tools.nix
    ./modules/shell.nix
    ./modules/alacritty.nix
    ./modules/bash.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/vim.nix

    # Phase 2A: 開発環境
    ./modules/vscode.nix
    ./modules/language-tools.nix

    # Phase 2B: WMツール
    ./modules/rofi.nix
    ./modules/wofi.nix
    ./modules/polybar.nix

    # Phase 3: デスクトップ環境
    ./modules/hyprland.nix
    ./modules/fcitx5.nix
    ./modules/xremap.nix

    # Phase 4: システムサービス（ユーザーレベル）
    ./modules/pipewire.nix

    # Phase 5: 追加設定
    ./modules/fonts.nix
    ./modules/applications.nix
    ./modules/themes.nix
  ];
}
