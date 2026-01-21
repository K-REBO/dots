{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    # システムパッケージとして有効化
    systemd.enable = true;
    xwayland.enable = true;

    # 設定ファイル
    # dots/config/hypr/hyprland.conf を使用
    # NixOSフル移行後は、以下のsettings属性で管理することを推奨
    extraConfig = builtins.readFile ../config/hypr/hyprland.conf;
  };

  # Hyprland関連パッケージ
  home.packages = with pkgs; [
    # Hyprland本体
    # hyprland  # 上記で有効化済み

    # Hyprlandエコシステム
    hyprlock      # スクリーンロッカー
    hypridle      # アイドル管理
    hyprpaper     # 壁紙管理（またはswww）

    # 壁紙 (swww)
    swww

    # スクリーンショット
    grimblast
    grim
    slurp
    satty         # スクリーンショット注釈

    # 通知
    dunst
    libnotify

    # その他ユーティリティ
    wl-clipboard  # Wayland clipboard
    brightnessctl # 輝度制御
    playerctl     # メディアプレイヤー制御

    # UIツール（既に他のモジュールで定義済みの場合はコメントアウト）
    # wofi
    # rofi-wayland

    # フォーカス管理（ローカルプロジェクト）
    # wmfocusはcargoでビルド済み

    # Hyprpanel (pacmanでインストール済み)
    # Hyprshell (pacmanでインストール済み)
  ];

  # hypridle設定
  # dots/config/hypr/hypridle.conf を使用
  xdg.configFile."hypr/hypridle.conf".source = ../config/hypr/hypridle.conf;

  # hyprlock設定
  # dots/config/hypr/hyprlock.conf を使用
  xdg.configFile."hypr/hyprlock.conf".source = ../config/hypr/hyprlock.conf;

  # 壁紙ディレクトリをコピー
  xdg.configFile."hypr/wallpapers".source = ../config/hypr/wallpapers;

  # スクリプトディレクトリをコピー
  xdg.configFile."hypr/scripts".source = ../config/hypr/scripts;

  # 環境変数（fcitx5用など）
  home.sessionVariables = {
    # Hyprland用
    XCURSOR_SIZE = "10";
    HYPRCURSOR_SIZE = "10";

    # fcitx5用（fcitx5.nixでも設定するが念のため）
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };
}
