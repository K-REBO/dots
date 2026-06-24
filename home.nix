{ config, pkgs, ... }:

{
  # ユーザー情報
  home.username = "bido";
  home.homeDirectory = "/home/bido";

  home.stateVersion = "25.11";

  # Home-Managerに管理を任せる
  programs.home-manager.enable = true;

  imports = [
    # CLIツール
    ./modules/home/cli-tools.nix
    ./modules/home/chuo.nix
    ./modules/home/cowsay.nix
    ./modules/home/fortune.nix
    ./modules/home/shell.nix
    ./modules/home/alacritty.nix
    ./modules/home/bash.nix
    ./modules/home/zsh.nix
    ./modules/home/git.nix
    ./modules/home/vim.nix

    # 開発環境
    ./modules/home/emacs.nix
    ./modules/home/vscode.nix
    ./modules/home/language-tools.nix

    # ランチャー / WMツール
    ./modules/home/wofi.nix
    ./modules/home/vicinae.nix

    # デスクトップ環境
    ./modules/home/hyprland.nix
    ./modules/home/fcitx5.nix
    ./modules/home/xremap.nix
    # ./modules/home/hyprpanel.nix  # ewwに移行のため無効化
    # ./modules/home/eww.nix        # quickshellに移行のため無効化
    ./modules/home/quickshell.nix

    # システムサービス（ユーザーレベル）
    ./modules/home/swaync.nix
    ./modules/home/pipewire.nix
    ./modules/home/taildrop.nix

    # 追加設定
    ./modules/home/fonts.nix
    ./modules/home/applications.nix
    ./modules/home/themes.nix
    ./modules/home/xdg.nix

    # WinApps
    ./modules/home/winapps.nix

    # Audio / DAW
    ./modules/home/audio.nix
  ];
}
