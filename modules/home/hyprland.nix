{ config, pkgs, lib, ... }:

let
  ocrPython = pkgs.python312.withPackages (ps: [ ps.manga-ocr ]);
  ocrDaemon = pkgs.writeText "ocr-daemon.py" ''
    import subprocess, tempfile, time, unicodedata, os
    from manga_ocr import MangaOcr

    mocr = MangaOcr()
    last_image = None

    while True:
        result = subprocess.run(
            ['${pkgs.wl-clipboard}/bin/wl-paste', '--type', 'image/png', '--no-newline'],
            capture_output=True
        )
        if result.returncode == 0 and result.stdout and result.stdout != last_image:
            last_image = result.stdout
            with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
                f.write(result.stdout)
                tmppath = f.name
            try:
                text = mocr(tmppath)
                text = unicodedata.normalize('NFKC', text)
                subprocess.run(['${pkgs.wl-clipboard}/bin/wl-copy'], input=text.encode(), check=True)
                subprocess.run(['${pkgs.libnotify}/bin/notify-send', 'OCR', text, '--expire-time=3000'])
            finally:
                os.unlink(tmppath)
        time.sleep(0.3)
  '';
  ocrScript = pkgs.writeShellScriptBin "ocr-screenshot" ''
    ${pkgs.grimblast}/bin/grimblast save area - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
  '';
in

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;  # NixOSモジュールのパッケージを使用

    # UWSM使用時はsystemd統合を無効化（必須）
    systemd.enable = false;
    xwayland.enable = true;

    # 設定ファイル
    # dots/config/hypr/hyprland.conf を使用
    # NixOSフル移行後は、以下のsettings属性で管理することを推奨
    extraConfig = builtins.readFile ../../config/hypr/hyprland.conf + ''

      # wmfocus (Nix store path)
      bind = $mainMod,i,exec,${pkgs.wmfocus}/bin/wmfocus --textcolorcurrent lightseagreen --font "UbuntuMono Nerd Font":120 --offset 5,5 --margin 0.1,0.2,0.2,0
      # wayland_fcitx5_indicator (IME mode indicator)
      exec-once = ${config.programs.wayland-fcitx5-indicator.package}/bin/wayland_fcitx5_indicator
      # manga-ocr daemon (clipboard モード、NFKC正規化付き)
      exec-once = ${ocrPython}/bin/python3 ${ocrDaemon}
      # OCR screenshot
      bind = CTRL, Print, exec, ${ocrScript}/bin/ocr-screenshot
    '';
  };

  # Hyprland関連パッケージ
  home.packages = with pkgs; [
    # Hyprland本体
    # hyprland  # 上記で有効化済み

    # Hyprlandエコシステム
    hyprlock      # スクリーンロッカー
    hypridle      # アイドル管理
    hyprpaper     # 壁紙管理（またはawww）

    # 壁紙 (awww)
    awww

    # スクリーンショット
    grimblast
    grim
    slurp
    satty         # スクリーンショット注釈
    ocrScript     # OCR screenshot (manga-ocr daemon 経由)

    # その他ユーティリティ
    wl-clipboard  # Wayland clipboard
    brightnessctl # 輝度制御
    playerctl     # メディアプレイヤー制御

    # UIツール（既に他のモジュールで定義済みの場合はコメントアウト）
    # wofi
    # rofi-wayland

    # Hyprpanel (status bar)
    hyprpanel
  ];

  # hypridle設定
  # dots/config/hypr/hypridle.conf を使用
  xdg.configFile."hypr/hypridle.conf".source = ../../config/hypr/hypridle.conf;

  # hyprlock設定
  # dots/config/hypr/hyprlock.conf を使用
  xdg.configFile."hypr/hyprlock.conf".source = ../../config/hypr/hyprlock.conf;

  # 壁紙ディレクトリをコピー
  xdg.configFile."hypr/wallpapers".source = ../../config/hypr/wallpapers;

  # スクリプトディレクトリをコピー
  xdg.configFile."hypr/scripts".source = ../../config/hypr/scripts;

  # xdg-desktop-portal-hyprland の起動改善
  # 問題: GDM greeter セッションで起動した後、ログイン時の Hyprland 切り替えで
  #       Wayland 接続が切断され SIGSEGV する（毎ブートの既知パターン）
  # 対策: HYPRLAND_INSTANCE_SIGNATURE がない環境では起動しない +
  #       クラッシュ後の回復タイミングを調整
  xdg.configFile."systemd/user/xdg-desktop-portal-hyprland.service.d/recovery.conf".text = ''
    [Unit]
    ConditionEnvironment=HYPRLAND_INSTANCE_SIGNATURE

    [Service]
    RestartSec=2
    StartLimitIntervalSec=30
    StartLimitBurst=3
  '';

  # 環境変数（fcitx5用など）
  home.sessionVariables = {
    # Hyprland用
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";

    # fcitx5用
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };
}
