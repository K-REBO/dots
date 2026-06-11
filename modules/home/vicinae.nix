{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ vicinae ];

  # VicinaeのQIcon::fromTheme()は /etc/profiles/per-user/<user>/share/icons (home-managerの
  # アイコンテーマ) を解決できず、Firefox等のアプリアイコンが汎用アイコンになってしまう。
  # ~/.icons はQt/GTKどちらからも参照される検索パスなので、Colloid-Darkとその
  # Inherits チェーン (Tela-dark, Papirus-Dark, hicolor, breeze) をシンボリックリンクして解決する。
  home.file = lib.listToAttrs (map (name: {
    name = ".icons/${name}";
    value.source = config.lib.file.mkOutOfStoreSymlink
      "/etc/profiles/per-user/${config.home.username}/share/icons/${name}";
  }) [ "Colloid-Dark" "Tela-dark" "Papirus-Dark" "hicolor" "breeze" ]);

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
      ExecStart = "${pkgs.vicinae}/bin/vicinae server --config %h/.config/vicinae/config.jsonc";
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
