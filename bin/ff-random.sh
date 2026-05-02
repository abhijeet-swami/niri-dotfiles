#!/bin/bash
DIR="$HOME/.config/fastfetch/profiles"
ln -sf "$(find "$DIR" -type f ! -name active.png | shuf -n1)" "$DIR/active.png"
fastfetch "$@"
