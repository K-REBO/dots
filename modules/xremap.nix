{ config, pkgs, ... }:

{
  # xremap設定ファイル
  xdg.configFile."xremap/config.yaml".source = ../config/xremap/config.yaml;

  # xremapパッケージ
  home.packages = with pkgs; [
    xremap
  ];

  # systemdユーザーサービスでxremapを起動
  # 注意: xremapにはroot権限が必要な場合があります
  # Waylandでは、input groupへの追加とudev ruleが必要です
  systemd.user.services.xremap = {
    Unit = {
      Description = "xremap - Key remapper for X11 and Wayland";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.xremap}/bin/xremap ${config.xdg.configHome}/xremap/config.yaml";
      Restart = "on-failure";
      RestartSec = 3;

      # xremapはinputデバイスへのアクセスが必要
      # ユーザーがinputグループに所属している必要があります
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
