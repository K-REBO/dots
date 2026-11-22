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
  #     PORTAL → tailscale set --accept-dns=false + ログイン画面をブラウザで開く
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

            # ログイン画面を自動で開く（セッション期限切れの再認証対策）
            # ブラウザは期限切れ前の DNS キャッシュで実IPに直接つなぎ、portal にリダイレクト
            # されず固まる。名前を引き直す平文 http のページを開いて portal に誘導する。
            # Hyprland 環境で GNOME の自動ポップアップは出ないため、ここで開く。
            ${pkgs.util-linux}/bin/runuser -u bido -- \
              env XDG_RUNTIME_DIR=/run/user/1000 \
                  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
                  WAYLAND_DISPLAY=wayland-1 \
              ${pkgs.xdg-utils}/bin/xdg-open "http://nmcheck.gnome.org/check_network_status.txt" || true
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
