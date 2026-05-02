#!/bin/bash

COMMENT=$(grep '^#light' ~/.config/wallust/wallust.toml)

if [[ -n "$COMMENT" ]]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-tmp'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
else
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark-tmp'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
fi

pkill -SIGUSR1 kitty
pkill waybar
waybar &
ln -sf ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css
killall mako
mako &
killall swayosd-server
swayosd-server -s ~/.config/swayosd/style.css &
pkill -SIGUSR1 nvim
bash ~/.config/bin/spotify.sh

exit 0
