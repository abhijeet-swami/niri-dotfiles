#!/usr/bin/env bash

set -euo pipefail

pkill -x rofi 2>/dev/null || true
sleep 0.05

shutdown="  Shutdown"
reboot="  Reboot"
lock="  Lock"
suspend="  Suspend"

run_rofi() {
  printf "%s\n" \
    "$lock" \
    "$suspend" \
    "$reboot" \
    "$shutdown" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi
}

run_cmd() {
  case "$1" in
  shutdown) systemctl poweroff ;;
  reboot) systemctl reboot ;;
  suspend) systemctl suspend ;;
  lock) hyprlock ;;
  esac
}

chosen="$(run_rofi)"

case "$chosen" in
"$shutdown") run_cmd shutdown ;;
"$reboot") run_cmd reboot ;;
"$lock") run_cmd lock ;;
"$suspend") run_cmd suspend ;;
esac
