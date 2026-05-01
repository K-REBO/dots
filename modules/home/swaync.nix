{ pkgs, ... }:

{
  services.swaync = {
    enable = true;

    settings = {
      cssPriority = "user";
      notification-window-width = 216;
      notification-icon-size = 48;
      image-visibility = "when-available";
    };

    style = ''
      * {
        font-family: "Noto Sans";
        font-size: 11pt;
        all: unset;
      }

      .blank-window {
        background: transparent;
      }

      .notification-row {
        outline: none;
        margin: 6px 12px;
      }

      .notification-background {
        padding: 0;
      }

      .notification {
        background-color: rgba(211, 234, 234, 0.5);
        border-radius: 14px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: 0 4px 24px rgba(0, 0, 0, 0.5);
      }

      .notification.critical {
        background-color: rgba(70, 28, 28, 0.75);
      }

      .notification-default-action {
        padding: 16px 14px 20px 14px;
        border-radius: 14px;
      }

      .notification-default-action:hover {
        background-color: rgb(56, 56, 60);
        border-radius: 14px;
      }

      .app-name {
        font-size: 9pt;
        font-weight: 600;
        color: rgba(235, 235, 245, 0.5);
        text-transform: uppercase;
        letter-spacing: 0.04em;
      }

      .time {
        font-size: 9pt;
        color: rgba(235, 235, 245, 0.4);
      }

      .summary {
        font-weight: bold;
        font-size: 11pt;
        color: #f0f0f0;
        margin-top: 2px;
      }

      .notification.critical .summary {
        color: #ff6b6b;
      }

      .body {
        font-size: 10.5pt;
        color: rgba(235, 235, 245, 0.6);
        margin-top: 2px;
      }

      .image {
        border-radius: 8px;
        margin-right: 10px;
      }

      .app-icon {
        border-radius: 8px;
        min-width: 48px;
        min-height: 48px;
        margin-right: 10px;
      }

      .close-button {
        background-color: rgba(255, 255, 255, 0.12);
        color: rgba(255, 255, 255, 0.6);
        min-width: 20px;
        min-height: 20px;
        border-radius: 50%;
        font-size: 9pt;
        margin: 8px 8px 0 0;
      }

      .close-button:hover {
        background-color: rgba(255, 255, 255, 0.22);
        color: #ffffff;
      }

      .control-center {
        background-color: rgba(28, 28, 30, 0.95);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 10px;
      }

      .control-center-list {
        background-color: transparent;
      }

      .control-center-list > row {
        background-color: transparent;
      }
    '';
  };

  systemd.user.services.swaync.serviceConfig.ExecStart = pkgs.lib.mkForce
    "${pkgs.swaynotificationcenter}/bin/swaync --skip-system-css";

  home.packages = [ pkgs.libnotify ];
}
