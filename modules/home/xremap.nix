{ config, pkgs, ... }:

{
  # xremap設定ファイル
  xdg.configFile."xremap/config.yaml".source = ../../config/xremap/config.yaml;

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
      # StartLimitIntervalSec/Burst は [Unit] セクションに置く必要がある
      StartLimitIntervalSec = 60;
      StartLimitBurst = 10;
    };

    Service = {
      Type = "simple";
      # --ignore xremap: 自分が作った仮想デバイスをgrabしないようにする
      # vicinae消滅後のデバイス再選択時に xremap 自身が候補に現れるため必須
      ExecStart = "${pkgs.xremap}/bin/xremap --ignore vicinae-snippet-virtual-keyboard --ignore xremap ${config.xdg.configHome}/xremap/config.yaml";
      Restart = "on-failure";
      RestartSec = 3;

      # xremapはinputデバイスへのアクセスが必要
      # ユーザーがinputグループに所属している必要があります
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
