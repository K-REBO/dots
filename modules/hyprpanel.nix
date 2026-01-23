{ config, pkgs, ... }:

{
  programs.hyprpanel = {
    enable = true;
    settings = {
      bar = {
        modules = {
          workspaces = {
            displayMode = "numbers";
          };
        };
      };
    };
  };
}
