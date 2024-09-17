#!/bin/bash


upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -i "time to empty" | awk '{print $4 $5}'
