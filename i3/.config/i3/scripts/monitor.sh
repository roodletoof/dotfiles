#!/bin/bash

if xrandr | grep -q "^HDMI-1 connected"; then
    # HDMI is connected
    xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
else
    # HDMI not connected, use laptop display
    xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
fi
