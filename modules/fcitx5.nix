{ config, pkgs, ... }:

{
  # fcitx5入力メソッド
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc        # 日本語入力（Mozc）
      fcitx5-gtk         # GTK統合
      fcitx5-configtool  # 設定ツール
    ];
  };

  # 環境変数
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # fcitx5パッケージ
  home.packages = with pkgs; [
    fcitx5
    fcitx5-mozc
    fcitx5-gtk
    fcitx5-qt
    fcitx5-configtool

    # wayland_fcitx5_indicatorはローカルプロジェクト（cargoでビルド済み）
  ];

  # dots/config/fcitx5/ の設定ファイルを使用
  xdg.configFile."fcitx5/config".source = ../config/fcitx5/config;
  xdg.configFile."fcitx5/profile".source = ../config/fcitx5/profile;
  xdg.configFile."fcitx5/conf".source = ../config/fcitx5/conf;
}
