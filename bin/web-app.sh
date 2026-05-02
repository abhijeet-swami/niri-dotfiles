#!/usr/bin/env bash

url="$1"
browser=$(xdg-settings get default-web-browser 2>/dev/null)

case "$browser" in
*firefox*)
  exec setsid firefox --no-remote -P "WebApps" --new-window --class WebApp "$url"
  ;;
*)
  exec setsid firefox --new-window "$url"
  ;;
esac
