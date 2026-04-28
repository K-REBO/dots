{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;

    settings = {
      width = 1200;
      height = 800;
      mode = "drun";
      colors = "colors";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      drun-display_generic = true;
      icon-theme = "Papirus";
    };

    # スタイルCSS
    style = ''
      window {
          margin: 5px;
          border: 0px solid #444444;
          background-color: rgba(0, 0, 0, 0.0);
          font-family: FontAwesome;
          font-size: 2rem;
      }

      @keyframes erscheinen {
          from {opacity: 0;}
            to {opacity: 1;}
      }

      #input {
          margin: 0px 0px 5px;
          border: 5px solid #b58900;
          background-color: rgb(7, 54, 66);
          border-radius: 20px;
          color: #fdf6e3;
      }

      #inner-box {
          margin: 0px;
          border: 0px solid #444444;
          background-color: rgba(68, 68, 68, 0.0);
      }

      #outer-box {
          margin: 0px;
          border: 0px solid rgb(203, 75, 22);
          background-color: rgba(0, 0, 0, 0.0);
      }

      #scroll {
          margin: 0px;
          border: 5px solid #586e75;
          border-radius: 0px;
          background-color: rgba(7, 54, 66, 0.9);
      }

      #text {
          margin: 1px;
          border: 0px solid #44AA44;
          color: #FFFFFF;
      }

      #selected {
          background-color: rgb(76, 162, 223);
      }
    '';
  };

  # papirus-icon-theme と font-awesome は themes.nix / fonts.nix で管理
}
