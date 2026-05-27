{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ vicinae ];

  xdg.configFile."vicinae/config.jsonc".source = ../../config/vicinae/config.jsonc;
  xdg.configFile."vicinae/settings.json" = {
    source = ../../config/vicinae/settings.json;
    force = true;
  };

  # home-manager switch 後にvicinaeのGIOアプリキャッシュをリロードする
  # （新しいdesktopエントリを認識させるため）
  home.activation.reloadVicinae = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -HUP vicinae 2>/dev/null || true
  '';
}
