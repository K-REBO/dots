{ config, pkgs, lib, inputs, enableHazkey, osConfig ? null, ... }:

let
  # NixOSのi18n.inputMethodで構成されたfcitx5(addon込み)パッケージ
  # standalone home-manager評価時はosConfigが無いため、configuration.nixの
  # i18n.inputMethod.fcitx5.addons と同じ構成をここで再現してフォールバックする。
  # (以前はpkgs.fcitx5(addonなし)にフォールバックしており、mozc/hazkeyアドオンが
  #  ロードされず profile の入力メソッドが invalid として除去されてしまっていた)
  fcitx5Package =
    if osConfig != null
    then osConfig.i18n.inputMethod.package
    else pkgs.qt6Packages.fcitx5-with-addons.override {
      addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ]
        ++ lib.optional enableHazkey inputs.nix-hazkey.packages.${pkgs.system}.fcitx5-hazkey;
    };
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

  # NixOSのi18n.inputMethod.fcitx5がXDG autostartエントリ
  # (/etc/xdg/autostart/org.fcitx.Fcitx5.desktop)を自動生成するが、
  # 下記のsystemd.user.services.fcitx5と二重起動し、D-Bus名(org.fcitx.Fcitx5)を
  # --replaceで奪い合った結果systemdサービス側がinactiveに追いやられるため、
  # ユーザーautostartにHidden=trueを置いて無効化する
  xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # dots/config/fcitx5/ の設定ファイルを使用
  xdg.configFile."fcitx5/config".source = ../../config/fcitx5/config;
  # enableHazkey=true: Hazkey(Zenzai)をデフォルトIMにし、mozcは切り替え用に残す
  # enableHazkey=false: 従来通りmozcのみの構成
  xdg.configFile."fcitx5/profile".source =
    if enableHazkey
    then ../../config/fcitx5/profile-hazkey
    else ../../config/fcitx5/profile;
  xdg.configFile."fcitx5/conf".source = ../../config/fcitx5/conf;

  # NixOSのi18n.inputMethod.fcitx5がenvironment.systemPackages経由で
  # fcitx5-with-addonsパッケージのD-Busアクティベーションファイル
  # (.../share/dbus-1/services/org.fcitx.Fcitx5.service, --replaceなしのfcitx5を起動)
  # をシステムのD-Busセッションバスに登録してしまう。これが下記
  # systemd.user.services.fcitx5と起動順序次第でD-Bus名(org.fcitx.Fcitx5)を
  # --replaceで奪い合い、結果としてsystemdサービス側が名前の所有権を失って
  # 自己終了(exit 0)し、Restart=on-failureでは復帰しないままになる
  # (例: hyprland起動直後にfcitx5が消える)。
  # dbus-brokerは$XDG_DATA_HOME/dbus-1/servicesをsystem-pathより優先するため、
  # ここで同名ファイルを上書きし、activation時はsystemdサービスをstartするだけにする
  xdg.dataFile."dbus-1/services/org.fcitx.Fcitx5.service".text = ''
    [D-BUS Service]
    Name=org.fcitx.Fcitx5
    Exec=${pkgs.systemd}/bin/systemctl --user start fcitx5.service
  '';

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
