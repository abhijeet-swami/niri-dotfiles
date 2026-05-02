#!/usr/bin/env bash
# =============================================================================
#  Niri Setup Installer
#  Repo: https://github.com/abhijeet-swami/niri-dotfiles
# =============================================================================

set -euo pipefail

DOTFILES_REPO="https://github.com/abhijeet-swami/niri-dotfiles"
DOTFILES_DIR="$HOME/.dotfiles_src"
BACKUP_DIR="$HOME/Documents/backup"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info() { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn() { echo "[WARN]  $*"; }
error() {
  echo "[ERROR] $*" >&2
  exit 1
}

ask_yn() {
  local prompt="$1"
  local answer
  while true; do
    read -rp "$prompt [y/n]: " answer
    case "$answer" in
    y | Y | yes | YES) return 0 ;;
    n | N | no | NO) return 1 ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# Root check
# -----------------------------------------------------------------------------
if [[ "$EUID" -eq 0 ]]; then
  error "Do not run this script as root. It will use sudo when needed."
fi

echo ""
echo "============================================"
echo "  Niri Setup Installer"
echo "============================================"
echo ""

# -----------------------------------------------------------------------------
# Step 1 – Detect existing dotfiles / fresh install
# -----------------------------------------------------------------------------
FRESH_INSTALL=true
if [[ -d "$HOME/.config" && "$(ls -A "$HOME/.config" 2>/dev/null)" ]]; then
  warn "Existing ~/.config detected."
  FRESH_INSTALL=false
fi

# -----------------------------------------------------------------------------
# Step 2 – Install yay if missing
# -----------------------------------------------------------------------------
install_yay() {
  if command -v yay &>/dev/null; then
    success "yay is already installed."
    return
  fi
  info "yay not found. Installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  local tmp
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
  success "yay installed."
}

install_yay

# -----------------------------------------------------------------------------
# Step 3 – Install packages
#
# -----------------------------------------------------------------------------
PACKAGES=(
  # WM & display
  niri
  xwayland-satellite
  xorg-xwayland

  # Audio / pipewire stack
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-pulse
  wireplumber
  gst-plugin-pipewire
  pamixer
  libpulse

  # Wayland utilities
  grim
  slurp
  wl-clipboard
  cliphist
  swayosd
  brightnessctl

  # Notifications & idle
  mako
  hypridle
  hyprlock

  # App launcher & color picker
  rofi
  hyprpicker

  # Wallpaper & theming
  awww
  wallust
  adw-gtk-theme
  gnome-themes-extra
  imagemagick

  # Bar
  waybar

  # Terminal & shell
  kitty
  zsh
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  zsh-syntax-highlighting
  starship

  # CLI tools
  neovim
  yazi
  btop
  bat
  eza
  fzf
  zoxide
  ripgrep
  fastfetch
  impala
  bluetui
  cava

  # Fonts
  ttf-jetbrains-mono-nerd
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  ttf-dejavu
  ttf-liberation
  woff2-font-awesome

  # Portal & polkit
  xdg-desktop-portal-gnome
  xdg-utils
  polkit-gnome
  gnome-keyring

  # Media
  mpv
  imv

  # System
  git
  base-devel
  python-gobject
  libnotify
  libva-utils
  unzip
  wget
)

info "Installing packages with yay (this may take a while)..."
yay -S --needed --noconfirm "${PACKAGES[@]}"
success "All packages installed."

# -----------------------------------------------------------------------------
# Step 4 – Clone dotfiles repo
# -----------------------------------------------------------------------------
info "Cloning dotfiles from $DOTFILES_REPO ..."
if [[ -d "$DOTFILES_DIR" ]]; then
  warn "$DOTFILES_DIR already exists. Pulling latest changes..."
  git -C "$DOTFILES_DIR" pull
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi
success "Dotfiles cloned to $DOTFILES_DIR."

# -----------------------------------------------------------------------------
# Step 5 – Backup existing ~/.config if not a fresh install
# -----------------------------------------------------------------------------
if [[ "$FRESH_INSTALL" == false ]]; then
  BACKUP_PATH="$BACKUP_DIR/config_$TIMESTAMP"
  info "Backing up ~/.config to $BACKUP_PATH ..."
  mkdir -p "$BACKUP_DIR"
  cp -r "$HOME/.config" "$BACKUP_PATH"
  success "Backup saved at $BACKUP_PATH"
fi

# -----------------------------------------------------------------------------
# Step 6 – Copy dotfiles into place
# -----------------------------------------------------------------------------
info "Copying dotfiles..."

if [[ -d "$DOTFILES_DIR/.config" ]]; then
  mkdir -p "$HOME/.config"
  cp -r "$DOTFILES_DIR/.config/." "$HOME/.config/"
  success "Copied .config"
fi

for f in "$DOTFILES_DIR"/.[^.]*; do
  fname=$(basename "$f")
  [[ "$fname" == ".config" || "$fname" == ".git" ]] && continue
  if [[ -e "$HOME/$fname" && "$FRESH_INSTALL" == false ]]; then
    info "Backing up ~/$fname -> $BACKUP_DIR/${fname}_$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/$fname" "$BACKUP_DIR/${fname}_$TIMESTAMP"
  fi
  cp -r "$f" "$HOME/$fname"
  success "Copied $fname"
done

# -----------------------------------------------------------------------------
# Step 7 – Wallpapers
# Copy Wallpapers/ from dotfiles repo into ~/Pictures/Wallpapers
# -----------------------------------------------------------------------------
info "Setting up wallpapers..."
mkdir -p "$WALLPAPER_DIR"

REPO_WALLS="$DOTFILES_DIR/Wallpapers"
if [[ -d "$REPO_WALLS" ]]; then
  cp -r "$REPO_WALLS/." "$WALLPAPER_DIR/"
  success "Wallpapers copied to $WALLPAPER_DIR"
else
  warn "No Wallpapers/ folder found in the dotfiles repo. An empty folder has been created."
fi

echo ""
echo "--------------------------------------------"
echo "  WALLPAPERS -> $WALLPAPER_DIR"
echo "--------------------------------------------"
echo ""
echo "  Add your wallpapers to that folder."
echo ""
echo "  LIGHT THEME:"
echo "  Prefix any wallpaper filename with 'light-'"
echo "  to automatically apply light theme when"
echo "  that wallpaper is selected."
echo ""
echo "  Example:"
echo "    mountain.jpg        -> dark theme"
echo "    light-mountain.jpg  -> light theme"
echo "--------------------------------------------"
echo ""

# -----------------------------------------------------------------------------
# Step 8 – Shell setup
# -----------------------------------------------------------------------------
if ask_yn "Do you want to set zsh as your default shell?"; then
  ZSH_PATH=$(command -v zsh)
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_PATH"
  success "Default shell set to zsh."
else
  info "Keeping bash as default shell."
  ZSHRC="$HOME/.zshrc"
  BASHRC="$HOME/.bashrc"
  if [[ -f "$ZSHRC" ]]; then
    info "Copying aliases from .zshrc into .bashrc ..."
    ALIAS_BLOCK=$(grep -E '^\s*alias ' "$ZSHRC" || true)
    if [[ -n "$ALIAS_BLOCK" ]]; then
      {
        echo ""
        echo "# --- Aliases imported from .zshrc by install.sh ---"
        echo "$ALIAS_BLOCK"
      } >>"$BASHRC"
      success "Aliases appended to .bashrc"
    else
      warn "No aliases found in .zshrc to copy."
    fi
  else
    warn ".zshrc not found, skipping alias copy."
  fi
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "============================================"
echo "  Installation complete!"
echo ""
echo "  Dotfiles source : $DOTFILES_DIR"
echo "  Wallpapers      : $WALLPAPER_DIR"
if [[ "$FRESH_INSTALL" == false ]]; then
  echo "  Config backup   : $BACKUP_DIR/config_$TIMESTAMP"
fi
echo ""
echo "  NEXT STEP"
echo "  ----------"
echo ""
echo "  Pick your wallpaper:"
echo "       Press  Mod + Ctrl + Shift + Space"
echo "       Use arrow keys or type to filter,"
echo "       then press Enter to apply."
echo ""
echo "     Remember: prefix the filename with 'light-'"
echo "     to auto-switch to light theme when selected."
echo "     Example: light-forest.jpg"
echo ""
