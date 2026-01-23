{ config, pkgs, ... }:

{
  # fcitx5入力メソッド
  # 注意: fcitx5のコア設定はNixOSシステムレベル（configuration.nix）で行われています
  # ここではユーザー設定ファイルのみを管理します

  # 追加パッケージ（configuration.nixに含まれていないもの）
  home.packages = with pkgs; [
    libsForQt5.fcitx5-qt           # Qt5統合
    qt6Packages.fcitx5-qt          # Qt6統合
    qt6Packages.fcitx5-configtool  # 設定ツール
  ];

  # dots/config/fcitx5/ の設定ファイルを使用
  xdg.configFile."fcitx5/config".source = ../config/fcitx5/config;
  xdg.configFile."fcitx5/profile".source = ../config/fcitx5/profile;
  xdg.configFile."fcitx5/conf".source = ../config/fcitx5/conf;
}
