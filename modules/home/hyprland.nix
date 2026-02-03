{ config, pkgs, lib, ... }:

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
    '';
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

  # 環境変数（fcitx5用など）
  home.sessionVariables = {
    # Hyprland用
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";

    # fcitx5用（GTK_IM_MODULE は Wayland では不要）
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };
}
