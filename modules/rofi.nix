{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;  # rofi-waylandはrofiに統合済み

    # 基本設定
    extraConfig = {
      # PATH設定
      # rofi設定ファイルに enviroment.path があったが、
      # これはNixのシェル環境変数で管理される
    };
  };

  # rofiが依存するパッケージ
  home.packages = with pkgs; [
    # アイコンテーマはwofiで使用
  ];
}
