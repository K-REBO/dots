{ config, pkgs, enableHazkey, osConfig ? null, ... }:

let
  # NixOSのi18n.inputMethodで構成されたfcitx5(addon込み)パッケージ
  # standalone home-manager評価時はosConfigが無いのでpkgs.fcitx5にフォールバック
  fcitx5Package =
    if osConfig != null
    then osConfig.i18n.inputMethod.package
    else pkgs.fcitx5;
in
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
  xdg.configFile."fcitx5/config".source = ../../config/fcitx5/config;
  # enableHazkey=true: Hazkey(Zenzai)をデフォルトIMにし、mozcは切り替え用に残す
  # enableHazkey=false: 従来通りmozcのみの構成
  xdg.configFile."fcitx5/profile".source =
    if enableHazkey
    then ../../config/fcitx5/profile-hazkey
    else ../../config/fcitx5/profile;
  xdg.configFile."fcitx5/conf".source = ../../config/fcitx5/conf;

  # systemd user serviceで管理（起動失敗時に自動再起動）
  systemd.user.services.fcitx5 = {
    Unit = {
      Description = "Fcitx5 Input Method";
      # xdg-desktop-portal-hyprland が安定してから起動することで
      # portal 再起動のタイミングと fcitx5 セッション初期化の衝突を防ぐ
      After = [ "graphical-session.target" "xdg-desktop-portal-hyprland.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      # -d (daemonize)を指定するとfork+親終了によりType=simpleのcgroupごとkillされるため付けない
      ExecStart = "${fcitx5Package}/bin/fcitx5 --replace";
      Restart = "on-failure";
      RestartSec = "3";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
