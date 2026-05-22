{ pkgs, ... }:

{
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "mute-on-chou-u" ''
        ACTION="$2"
        if [ "$ACTION" = "up" ] && [ "$CONNECTION_ID" = "CHOU-U" ]; then
          XDG_RUNTIME_DIR=/run/user/1000 \
            su - bido -c "pactl set-sink-mute @DEFAULT_SINK@ 1"
        fi
      '';
      type = "basic";
    }
  ];
}
