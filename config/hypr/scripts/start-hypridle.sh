#!/usr/bin/env bash
STATE="$HOME/.local/share/hypridle/dpms-timeout"
CONFIG="$HOME/.config/hypr/hypridle.conf"
DPMS_DEFAULT=300
LOCK_TIMEOUT=3000

mkdir -p "$(dirname "$STATE")"
[ -f "$STATE" ] || echo "$DPMS_DEFAULT" > "$STATE"
DPMS=$(cat "$STATE")

rm -f "$CONFIG"

if [ "$DPMS" = "0" ]; then
  cat > "$CONFIG" <<EOF
general {
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}
listener {
    timeout = $LOCK_TIMEOUT
    on-timeout = hyprlock
    on-resume = hyprctl dispatch dpms on
}
EOF
else
  cat > "$CONFIG" <<EOF
general {
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}
listener {
    timeout = $LOCK_TIMEOUT
    on-timeout = hyprlock
    on-resume = hyprctl dispatch dpms on
}
listener {
    timeout = $DPMS
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
EOF
fi

exec hypridle
