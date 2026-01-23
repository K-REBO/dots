{ config, pkgs, ... }:

{
  programs.hyprpanel = {
    enable = true;
    settings = {
      bar.workspaces.show_numbered = true;
    };
  };
}
