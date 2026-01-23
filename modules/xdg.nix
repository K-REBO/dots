{ config, pkgs, ... }:

{
  # XDGユーザーディレクトリ設定
  xdg.userDirs = {
    enable = true;
    createDirectories = false;  # 自動作成しない

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
}
