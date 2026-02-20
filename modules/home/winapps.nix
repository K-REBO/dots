{ config, pkgs, lib, ... }:

{
  # ~/.config/winapps/winapps.conf を Home Manager で管理
  xdg.configFile."winapps/winapps.conf" = {
    text = ''
      RDP_USER="bido"
      RDP_PASS="CHANGE_ME"
      RDP_IP="127.0.0.1"
      RDP_DOMAIN=""

      # libvirt を使わず手動 RDP 接続（start-windows-vm スクリプトで起動）
      WAFLAVOR="manual"
      RDP_SCALE=100

      FREERDP_COMMAND="xfreerdp"

      # Linux 側のディレクトリを Windows VM に共有（\\tsclient\Music\ でアクセス）
      RDP_FLAGS="/drive:Music,/home/bido/music"

      DEBUG=0
      PORT_TIMEOUT=30
      RDP_TIMEOUT=15
      APP_SCAN_TIMEOUT=100
    '';
  };

  # iTunes カスタムアプリ定義
  xdg.dataFile."winapps/apps/itunes/info" = {
    text = ''
      AppName=iTunes
      Exec=C:\Program Files\iTunes\iTunes.exe
      Name=iTunes
      Categories=AudioVideo;Music;Player;
    '';
  };
}
