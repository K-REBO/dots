{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        opacity = 0.8;
        dimensions = {
          columns = 80;
          lines = 24;
        };
        decorations = "full";
        title = "Alacritty";
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 1300;
      };

      font = {
        normal = {
          family = "UbuntuMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "UbuntuMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "UbuntuMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "UbuntuMono Nerd Font";
          style = "Bold Italic";
        };
        size = 18.0;
      };

      # Gnome Dark カラースキーム
      colors = {
        primary = {
          foreground = "#d0cfcc";
          background = "#380C2A";
          bright_foreground = "#ffffff";
        };

        normal = {
          black = "#171421";
          red = "#c01c28";
          green = "#26a269";
          yellow = "#a2734c";
          magenta = "#a347ba";
          cyan = "#2aa1b3";
        };
      };

      keyboard.bindings = [
        {
          key = "F11";
          command = {
            program = "wmctrl";
            args = [ "-r" ":ACTIVE:" "-b" "toggle,fullscreen" ];
          };
        }
      ];
    };
  };
}
