{ config, pkgs, ... }:

{
  programs.hyprpanel = {
    enable = true;
    systemd.enable = false;  # exec-onceで起動
    settings = {
      bar.workspaces.show_numbered = true;
    };
  };
}
