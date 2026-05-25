{ config, pkgs, ... }:

let
  # stdout Broken Pipe対策: vicinaeがパイプを閉じてもクラッシュしないようにラップ
  bitwigWrapper = pkgs.writeShellScript "bitwig-studio-wrapped" ''
    exec /etc/profiles/per-user/bido/bin/bitwig-studio >/dev/null 2>&1
  '';
in
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

  # Bitwigのデスクトップエントリをフルパスで上書き（VicianがPATHを引き継がない + stdout Broken Pipe対策）
  xdg.desktopEntries."com.bitwig.BitwigStudio" = {
    name = "Bitwig Studio";
    genericName = "Digital Audio Workstation";
    comment = "Modern music production and performance";
    exec = "${bitwigWrapper}";
    icon = "com.bitwig.BitwigStudio";
    terminal = false;
    categories = [ "AudioVideo" "Music" "Audio" "Sequencer" "Midi" "Mixer" "Player" "Recorder" ];
    mimeType = [
      "application/bitwig-clip"
      "application/bitwig-device"
      "application/bitwig-package"
      "application/bitwig-preset"
      "application/bitwig-project"
      "application/bitwig-scene"
      "application/bitwig-template"
      "application/bitwig-extension"
      "application/bitwig-remote-controls"
      "application/bitwig-module"
      "application/bitwig-modulator"
      "application/vnd.bitwig.dawproject"
    ];
    startupNotify = true;
    settings = {
      StartupWMClass = "com.bitwig.BitwigStudio";
    };
  };

  # デフォルトブラウザをFirefoxに設定（未設定だとmimeinfo.cacheのアルファベット順でChromeになる）
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"                = [ "firefox.desktop" ];
      "x-scheme-handler/http"    = [ "firefox.desktop" ];
      "x-scheme-handler/https"   = [ "firefox.desktop" ];
      "x-scheme-handler/ftp"     = [ "firefox.desktop" ];
      "application/xhtml+xml"    = [ "firefox.desktop" ];
      "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
    };
  };

}
