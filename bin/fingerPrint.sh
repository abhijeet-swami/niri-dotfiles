#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print() { echo -e "$1"; }
info() { echo -e "${YELLOW}$1${NC}"; }
succ() { echo -e "${GREEN}$1${NC}"; }
err() { echo -e "${RED}$1${NC}"; }

if [[ "$EUID" -eq 0 ]]; then
  err "Do NOT run this script as root / sudo."
  err "Run it as your normal user: ./fingerPrint.sh"
  exit 1
fi

backup_file() {
  local f="$1"
  if [ -f "$f" ]; then
    sudo cp "$f" "${f}.bak.$(date +%s)"
    info "Backed up $f"
  fi
}

insert_pam_if_missing() {
  local file="$1"
  local line="$2"
  if [ ! -f "$file" ]; then
    info "$file does not exist — creating minimal one..."
    sudo tee "$file" >/dev/null <<'EOF'
auth      sufficient pam_fprintd.so
auth      required   pam_unix.so
account   required   pam_unix.so
password  required   pam_unix.so
session   required   pam_unix.so
EOF
    return
  fi
  if ! sudo grep -Fq "pam_fprintd.so" "$file"; then
    sudo sed -i "1i $line" "$file"
    info "Inserted PAM line into $file"
  else
    info "PAM line already present in $file"
  fi
}

fix_broken_pam_lines() {
  local file="$1"
  if [ -f "$file" ] && sudo grep -q 'pam_\[fprintd' "$file"; then
    sudo sed -i 's|pam_\[fprintd\.so\](http://fprintd\.so)|pam_fprintd.so|g' "$file"
    info "Fixed broken PAM lines in $file"
  fi
}

remove_pam_line() {
  local file="$1"
  local pattern="$2"
  if [ -f "$file" ] && sudo grep -Eq "$pattern" "$file"; then
    sudo sed -i "/$pattern/d" "$file"
    info "Removed PAM fprintd entries from $file"
  else
    info "No fprintd PAM entries to remove from $file"
  fi
}

if [[ "${1:-}" == "--remove" ]]; then
  succ "Removing fingerprint integration..."
  fprintd-delete "$USER" 2>/dev/null || true
  sudo fprintd-delete root 2>/dev/null || true
  remove_pam_line /etc/pam.d/sudo 'pam_fprintd\.so'
  remove_pam_line /etc/pam.d/polkit-1 'pam_fprintd\.so'
  sudo pacman -Rns --noconfirm fprintd 2>/dev/null || info "fprintd not installed or already removed."
  succ "Done."
  exit 0
fi

succ "Setting up fingerprint authentication..."
info "Running as user: $USER"

sudo pacman -S --noconfirm --needed fprintd usbutils
sudo systemctl enable --now fprintd

if ! lsusb | grep -Eiq 'fingerprint|synaptics|goodix|elan|validity|fpc'; then
  err "No fingerprint device detected via lsusb. Aborting."
  exit 1
fi
succ "Fingerprint hardware detected."

fix_broken_pam_lines /etc/pam.d/sudo
fix_broken_pam_lines /etc/pam.d/polkit-1

backup_file /etc/pam.d/sudo
backup_file /etc/pam.d/polkit-1

insert_pam_if_missing /etc/pam.d/sudo 'auth    sufficient pam_fprintd.so'
insert_pam_if_missing /etc/pam.d/polkit-1 'auth    sufficient pam_fprintd.so'

sudo fprintd-delete root 2>/dev/null || true
fprintd-delete "$USER" 2>/dev/null || true

info "Starting enrollment for user: $USER"
info "Place and lift your finger repeatedly until enrollment completes."
echo ""

if fprintd-enroll "$USER"; then
  succ "Enrollment successful! Verifying..."
  echo ""
  if fprintd-verify "$USER"; then
    succ "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    succ " Fingerprint authentication is ready!"
    succ " Works for: sudo, polkit prompts"
    succ "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  else
    err "Verification failed. Try: fprintd-enroll $USER"
  fi
else
  err "Enrollment failed."
  err "If you see 'enroll-duplicate', run: sudo fprintd-delete root"
  exit 1
fi
