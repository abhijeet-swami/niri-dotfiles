#!/bin/bash
WIN=$(niri msg -j windows | jq -r '.[] | select(.app_id == "scratchpad") | .id')

if [ -z "$WIN" ]; then
  kitty --class scratchpad &
else
  FOCUSED=$(niri msg -j focused-window | jq -r '.app_id')
  if [ "$FOCUSED" = "scratchpad" ]; then
    niri msg action toggle-window-floating
    niri msg action minimize-window
  else
    niri msg action focus-window --id "$WIN"
  fi
fi
