{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ vicinae ];

  xdg.configFile."vicinae/config.jsonc".source = ../../config/vicinae/config.jsonc;
  xdg.configFile."vicinae/settings.json" = {
    source = ../../config/vicinae/settings.json;
    force = true;
  };

  # systemdサービスとして管理: pkill -HUP はVicinaeを終了させるだけで再起動しないため
  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae application launcher";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server";
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # home-manager switch 後にvicinaeのGIOアプリキャッシュをリロードする
  # （新しいdesktopエントリを認識させるため）
  home.activation.reloadVicinae = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD systemctl --user restart vicinae.service 2>/dev/null || true
  '';
}
