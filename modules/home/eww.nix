{ config, pkgs, ... }:

{
  # eww (ElKowars wacky widgets)
  programs.eww = {
    enable = true;
    configDir = ../../config/eww;
  };

  # 依存パッケージ
  home.packages = with pkgs; [
    jq                # JSON processing
    socat             # Hyprland IPC
    brightnessctl     # Brightness control
    playerctl         # Media player control
    bluez             # Bluetooth
    networkmanager    # WiFi (nmcli)
  ];
}
