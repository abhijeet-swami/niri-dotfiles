#!/bin/bash

chosen=$(printf "󰌪  Performance\n󰾆  Balanced\n󰌩  Powersave" | rofi -dmenu -p "  Power Mode" \
  -theme ~/.config/rofi/performance.rasi)

case "$chosen" in
"󰌪  Performance")
  powerprofilesctl set performance
  notify-send "Power Mode" "Performance"
  ;;
"󰾆  Balanced")
  powerprofilesctl set balanced
  notify-send "Power Mode" "Balanced"
  ;;
"󰌩  Powersave")
  powerprofilesctl set power-saver
  notify-send "Power Mode" "Powersave"
  ;;
esac
