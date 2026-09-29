{ pkgs, ... }:

{
  # 中央大学のWi-Fi (CHUO-U) に接続したら自動で音声をミュートする
  #
  # 注意点:
  #   - su - は環境変数を破棄し、/etc/pam.d/su に pam_systemd が無いため
  #     XDG_RUNTIME_DIR が引き継がれない。runuser + env で明示的に渡す
  #   - PipeWire構成 (services.pulseaudio.enable = false) のため pactl は無い。
  #     wpctl を使う (config/quickshell/services/AudioService.qml と揃える)
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "mute-on-chuo-u" ''
        ACTION="$2"
        if [ "$ACTION" = "up" ] && [ "$CONNECTION_ID" = "CHUO-U" ]; then
          ${pkgs.util-linux}/bin/runuser -u bido -- \
            env XDG_RUNTIME_DIR=/run/user/1000 \
            ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
        fi
      '';
      type = "basic";
    }
  ];
}
