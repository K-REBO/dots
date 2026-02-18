{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ vicinae ];

  xdg.configFile."vicinae/config.jsonc".source = ../../config/vicinae/config.jsonc;
  xdg.configFile."vicinae/settings.json".source = ../../config/vicinae/settings.json;
}
