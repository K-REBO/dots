{ pkgs, ... }:

{
  # 通知デーモンは Quickshell (NotificationServer) に置き換えたため無効化。
  # org.freedesktop.Notifications の DBus 名は単一プロセスしか保持できない。
  services.swaync.enable = false;

  home.packages = [ pkgs.libnotify ];
}
