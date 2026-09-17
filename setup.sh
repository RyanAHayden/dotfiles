#!/bin/bash
# Deploys the sddm theme, boot logo, and limine theme onto the live system.
# Safe to re-run any time (e.g. after `omarchy refresh sddm`/`omarchy refresh limine`).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> dotfiles setup"

sudo pacman -S stow
stow $DOTFILES --adopt
chmod +x ~/.local/bin/*
omarchy theme install https://github.com/RyanAHayden/ryha-omarchy-theme

echo "==> sddm theme (omarchy-red)"
sudo cp -r "$DOTFILES/etc/sddm-themes/omarchy-red" /usr/share/sddm/themes/omarchy-red
sudo cp "$DOTFILES/etc/sddm.conf.d/10-theme.conf" /etc/sddm.conf.d/10-theme.conf

echo "==> boot logo (plymouth, via ryha-omarchy theme)"
omarchy plymouth set by theme ryha-omarchy

echo "==> limine boot menu theme"
entries_line=$(grep -n "^/" /boot/limine.conf | head -1 | cut -d: -f1)
sudo bash -c "
  tail -n +$entries_line /boot/limine.conf > /tmp/limine-entries.conf
  cat '$DOTFILES/etc/limine/theme-header.conf' /tmp/limine-entries.conf > /boot/limine.conf
  rm /tmp/limine-entries.conf
"

echo "Done - check git changes since we adopted your default files"
