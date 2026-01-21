#!/bin/bash

if pgrep -x "hypridle" > /dev/null
then
    pkill -x "hypridle"
    notify-send "Hypridle Disabled"
else
    hypridle &
    notify-send "Hypridle Enabled"
fi
