#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/thumbnails/bgselector"
CACHE_INDEX="$CACHE_DIR/.index"

mkdir -p "$CACHE_DIR"

current_index=$(mktemp)
find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.avif' \) -printf '%p\n' >"$current_index"

if [ -f "$CACHE_INDEX" ]; then
  while read -r cached_path; do
    if [ ! -f "$cached_path" ]; then
      rel_path="${cached_path#$WALL_DIR/}"
      cache_name="${rel_path//\//_}"
      cache_name="${cache_name%.*}.jpg"
      rm -f "$CACHE_DIR/$cache_name"
    fi
  done <"$CACHE_INDEX"
fi

progress_file=$(mktemp)
touch "$progress_file"

max_jobs=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
job_count=0

to_generate=$(mktemp)
while read -r img; do
  rel_path="${img#$WALL_DIR/}"
  cache_name="${rel_path//\//_}"
  cache_name="${cache_name%.*}.jpg"
  cache_file="$CACHE_DIR/$cache_name"

  [ -f "$cache_file" ] || echo "$img" >>"$to_generate"
done <"$current_index"

generate_thumbnail() {
  local img="$1"
  local cache_dir="$2"
  local wall_dir="$3"
  local progress="$4"
  local rel_path="${img#$wall_dir/}"
  local cache_name="${rel_path//\//_}"
  cache_name="${cache_name%.*}.jpg"
  local cache_file="$cache_dir/$cache_name"

  if [[ "$img" =~ \.(gif|GIF)$ ]]; then
    magick "$img[0]" -define jpeg:size=600x600 -filter Lanczos -strip \
      -thumbnail 300x300^ -gravity center -extent 300x300 \
      -quality 85 +repage "$cache_file" 2>/dev/null
  else
    magick "$img" -define jpeg:size=600x600 -filter Lanczos -strip \
      -thumbnail 300x300^ -gravity center -extent 300x300 \
      -quality 85 +repage "$cache_file" 2>/dev/null
  fi

  [ -f "$cache_file" ] && echo "1" >>"$progress"
}
export -f generate_thumbnail

if command -v xargs >/dev/null 2>&1 && [ -s "$to_generate" ]; then
  cat "$to_generate" | xargs -P "$max_jobs" -I {} bash -c \
    'generate_thumbnail "$1" "$2" "$3" "$4"' _ {} "$CACHE_DIR" "$WALL_DIR" "$progress_file"
elif [ -s "$to_generate" ]; then
  while read -r img; do
    generate_thumbnail "$img" "$CACHE_DIR" "$WALL_DIR" "$progress_file" &
    ((job_count++))
    if [ $((job_count % max_jobs)) -eq 0 ]; then
      wait -n 2>/dev/null || wait
    fi
  done <"$to_generate"
  wait
fi

rm -f "$to_generate"

total_generated=$(wc -l <"$progress_file" 2>/dev/null || echo 0)
[ $total_generated -gt 0 ] && echo "Generated $total_generated thumbnails" || echo "Cache up to date"
rm -f "$progress_file"

mv "$current_index" "$CACHE_INDEX"

rofi_input=$(mktemp)
while read -r img; do
  rel_path="${img#$WALL_DIR/}"
  cache_name="${rel_path//\//_}"
  cache_name="${cache_name%.*}.jpg"
  cache_file="$CACHE_DIR/$cache_name"

  [ -f "$cache_file" ] && printf '%s\000icon\037%s\n' "$rel_path" "$cache_file"
done <"$CACHE_INDEX" >"$rofi_input"

selected=$(rofi -dmenu -show-icons -config "$HOME/.config/rofi/bgselector/style.rasi" <"$rofi_input")
rm "$rofi_input"

if [ -n "$selected" ]; then
  selected_path="$WALL_DIR/$selected"
  if [ -f "$selected_path" ]; then
    ln -sf "$selected_path" "$WALL_DIR/current"
    awww img "$selected_path" -t fade --transition-duration 2 --transition-fps 30 &
    sleep 0.2

    filename=$(basename "$selected_path")

    CONFIG_DIR="$HOME/.config/wallust"
    LIGHT="$CONFIG_DIR/light.toml"
    DARK="$CONFIG_DIR/dark.toml"
    ACTIVE="$CONFIG_DIR/wallust.toml"

    [ -L "$ACTIVE" ] && rm "$ACTIVE"

    if [[ "${filename,,}" == light* ]]; then
      ln -s "$LIGHT" "$ACTIVE"
    else
      ln -s "$DARK" "$ACTIVE"
    fi
    sleep 0.1

    wallust run "$selected_path"

    wait
    magick "$selected_path" -resize 560x "$HOME/.cache/rofi-wallpaper.png" &
    bash ~/.config/bin/post-hook.sh
  fi
fi
