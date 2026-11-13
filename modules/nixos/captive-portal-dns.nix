{ config, pkgs, ... }:

{
  # captive portal のログイン完了までは Tailscale の DNS (MagicDNS) を無効にする
  #
  # 背景:
  #   MagicDNS が有効だと resolv.conf が 100.100.100.100 だけになり、
  #   tailscaled がカフェの DNS へ転送する。ログイン前はその DNS が応答しないため
  #   タイムアウト(context deadline exceeded)が積み重なり、portal 画面を開くのに時間がかかる。
  #
  # 動作:
  #   NetworkManager の connectivity-change を契機に切り替える
  #     PORTAL → tailscale set --accept-dns=false
  #     FULL   → tailscale set --accept-dns=true  (MagicDNS を戻す)
  #   LIMITED / NONE では何もしない（状態を変えない）
  #
  # 前提: networking.networkmanager.settings.connectivity が有効であること
  #       (hosts/nixos/configuration.nix)
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "tailscale-dns-for-captive-portal" ''
        ACTION="$2"
        [ "$ACTION" = "connectivity-change" ] || exit 0

        case "$CONNECTIVITY_STATE" in
          PORTAL)
            ${config.services.tailscale.package}/bin/tailscale set --accept-dns=false || true
            ;;
          FULL)
            ${config.services.tailscale.package}/bin/tailscale set --accept-dns=true || true
            ;;
        esac
      '';
      type = "basic";
    }
  ];
}
