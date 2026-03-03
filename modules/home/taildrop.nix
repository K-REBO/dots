# modules/home/taildrop.nix
# Taildrop - Tailscaleのファイル転送機能（受信側）の設定
# 参考: https://davideger.github.io/blog/taildrop_on_linux.html
#
# このモジュールがやること:
#   - 受信待機デーモン (tailreceive) をユーザーsystemdサービスとして登録
#   - 受信ファイルを ~/downloads に自動保存
#   - macOS等から送られたNFDファイル名をNFCに自動変換
#
# 前提条件 (configuration.nixに設定済み):
#   services.tailscale.enable = true;
#   networking.firewall.trustedInterfaces = [ "tailscale0" ];
#
# 【初回のみ手動実行が必要】
#   sudo tailscale up --operator=bido
# → これにより sudo なしで tailscale コマンドを実行できるようになる
# → 一度設定すれば以後は不要
#
# Tailscale管理画面でファイル送信機能を有効にすること:
#   https://login.tailscale.com/admin/settings/features

{ config, pkgs, ... }:

let
  taildropScript = pkgs.writeShellScript "taildrop" ''
    dir="$HOME/downloads"
    mkdir -p "$dir"

    # NFD→NFC正規化: ファイル着信を監視してリネーム（バックグラウンド）
    # macOSはファイル名をNFD（濁点を結合文字で表現）で送信するため、
    # Linuxで濁点が2文字に見えたり検索できない問題を修正する
    ${pkgs.inotify-tools}/bin/inotifywait \
      --monitor \
      --event close_write \
      --event moved_to \
      --format '%f' \
      "$dir" \
    | while IFS= read -r filename; do
        nfc=$(${pkgs.python3}/bin/python3 -c \
          "import unicodedata,sys; sys.stdout.write(unicodedata.normalize('NFC',sys.argv[1]))" \
          "$filename")
        if [ "$filename" != "$nfc" ]; then
          mv -- "$dir/$filename" "$dir/$nfc"
          echo "NFC normalized: $filename -> $nfc"
        fi
      done &

    # Tailscaleファイル受信（メインプロセス）
    # tailscale file get オプション:
    #   --loop    : 終了せず受信待機し続ける（デーモン動作）
    #   --verbose : 受信ログを詳細に出力
    exec ${pkgs.tailscale}/bin/tailscale file get --verbose --loop "$dir"
  '';
in

{
  # ============================
  # Taildrop 受信サービス
  # ============================
  systemd.user.services.taildrop = {
    Unit = {
      Description = "Taildrop File Receiver Service";

      # ネットワーク接続後に起動
      After = [ "network-online.target" ];
    };

    Service = {
      # 受信ファイルのパーミッションをオーナーのみに制限（セキュリティ対策）
      # 0077 = owner: rwx, group: ---, others: ---
      UMask = "0077";

      ExecStart = "${taildropScript}";

      # サービスがクラッシュした場合は自動再起動
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      # ユーザーログイン時に自動起動
      WantedBy = [ "default.target" ];
    };
  };
}
