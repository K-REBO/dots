{ config, pkgs, ... }:

{
  # XDG Desktop Portal設定（Hyprland用）
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  # XDGユーザーディレクトリ設定
  xdg.userDirs = {
    enable = true;
    createDirectories = false;  # 自動作成しない
    setSessionVariables = true;  # XDG環境変数をセッションにエクスポート（26.05以降のデフォルト変更を明示）

    # 既存のフォルダを使用
    download = "${config.home.homeDirectory}/downloads";

    # 不要なディレクトリはホームに設定（作成されない）
    desktop = config.home.homeDirectory;
    documents = config.home.homeDirectory;
    music = config.home.homeDirectory;
    pictures = config.home.homeDirectory;
    publicShare = config.home.homeDirectory;
    templates = config.home.homeDirectory;
    videos = config.home.homeDirectory;
  };

  # 既存ファイルを上書き
  xdg.configFile."user-dirs.dirs".force = true;

  # デフォルトブラウザをFirefoxに設定
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
