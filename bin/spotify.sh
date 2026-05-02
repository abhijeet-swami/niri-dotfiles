#!/usr/bin/env bash

COLOR_FILE="$HOME/.config/spicetify/Themes/wallust/color.ini"

# --- 1. Remove only '#' from color values ---
if [[ -f "$COLOR_FILE" ]]; then
  sed -i 's/#//g' "$COLOR_FILE"
else
  echo "Color file not found: $COLOR_FILE"
  exit 1
fi

# --- 2. Check if Spotify is running ---
if pgrep -x spotify >/dev/null; then
  SPOTIFY_RUNNING=true
else
  SPOTIFY_RUNNING=false
fi

# --- 3. Apply spicetify ---
spicetify apply

# --- 4. If Spotify wasn't running before, close it ---
if [[ "$SPOTIFY_RUNNING" = false ]]; then
  pkill -x spotify 2>/dev/null
fi
