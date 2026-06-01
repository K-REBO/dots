{ config, pkgs, ... }:

let
  # stdout Broken Pipe対策: vicinaeがパイプを閉じてもクラッシュしないようにラップ
  bitwigWrapper = pkgs.writeShellScript "bitwig-studio-wrapped" ''
    if ! ${pkgs.procps}/bin/pgrep -f 'com.bitwig.flt.app.BitwigStudioMain' > /dev/null 2>&1; then
      # クラッシュ後に残る /dev/shm/bitwig-posix-bido を削除しないと
      # ランチャーが「起動中」と誤認識し IPCタイムアウト（約10分）まで待ち続ける
      rm -rf /dev/shm/bitwig-posix-bido 2>/dev/null || true
      rm -f "$HOME/.BitwigStudio/lock" "$HOME/.BitwigStudio/lock.pid" 2>/dev/null || true

      ${pkgs.libnotify}/bin/notify-send \
        --icon=com.bitwig.BitwigStudio \
        --app-name="Bitwig Studio" \
        -t 30000 \
        "Bitwig Studio" "起動中..." &
    fi
    exec uwsm app -- /etc/profiles/per-user/bido/bin/bitwig-studio
  '';
  # boot後初回起動時にworkspace 1へ飛ぶ問題の修正:
  # vicinaeはuwsmを経由しないためHyprlandがワークスペースコンテキストを受け取れず
  # workspace 1に配置してしまう。uwsm app -- で起動することで正常動作する。
  firefoxWrapper = pkgs.writeShellScript "firefox-wrapped" ''
    exec uwsm app -- firefox "$@"
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

  # Firefoxのデスクトップエントリを上書き
  # システムの firefox.desktop は Exec=firefox --name firefox %U のため uwsm を経由しない
  # ~/.local/share/applications/ に置くことでシステムのものより優先される
  home.file.".local/share/applications/firefox.desktop".text = ''
    [Desktop Entry]
    Actions=new-private-window;new-window;profile-manager-window
    Categories=Network;WebBrowser
    Exec=${firefoxWrapper} %U
    GenericName=Web Browser
    Icon=firefox
    MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https
    Name=Firefox
    StartupNotify=true
    StartupWMClass=firefox
    Terminal=false
    Type=Application
    Version=1.5

    [Desktop Action new-private-window]
    Exec=${firefoxWrapper} --private-window %U
    Name=New Private Window

    [Desktop Action new-window]
    Exec=${firefoxWrapper} --new-window %U
    Name=New Window

    [Desktop Action profile-manager-window]
    Exec=${firefoxWrapper} --ProfileManager
    Name=Profile Manager
  '';

  # Bitwigのデスクトップエントリを ~/.local/share/applications/ に直接配置
  # vicinae は XDG_DATA_DIRS を引き継がず ~/.nix-profile/share が見えないため
  # ~/.local/share/applications/ は常に参照されるのでここに置く
  home.file.".local/share/applications/com.bitwig.BitwigStudio.desktop".text = ''
    [Desktop Entry]
    Version=1.5
    Type=Application
    Name=Bitwig Studio
    GenericName=Digital Audio Workstation
    Comment=Modern music production and performance
    Exec=${bitwigWrapper}
    Icon=com.bitwig.BitwigStudio
    Terminal=false
    MimeType=application/bitwig-clip;application/bitwig-device;application/bitwig-package;application/bitwig-preset;application/bitwig-project;application/bitwig-scene;application/bitwig-template;application/bitwig-extension;application/bitwig-remote-controls;application/bitwig-module;application/bitwig-modulator;application/vnd.bitwig.dawproject
    Categories=AudioVideo;Music;Audio;Sequencer;Midi;Mixer;Player;Recorder
    Keywords=daw;bitwig;audio;midi
    StartupNotify=true
    StartupWMClass=com.bitwig.BitwigStudio
  '';

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
