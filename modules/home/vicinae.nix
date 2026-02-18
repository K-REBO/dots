{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ vicinae ];

  xdg.configFile."vicinae/config.jsonc".source = ../../config/vicinae/config.jsonc;
}
