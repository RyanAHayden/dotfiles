#!/bin/bash
# Deploys the sddm theme, boot logo, and limine theme onto the live system.
# Safe to re-run any time (e.g. after `omarchy refresh sddm`/`omarchy refresh limine`).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> dotfiles setup"

command -v stow >/dev/null || sudo pacman -S stow
cd "$DOTFILES"
stow . --adopt
# .local is stowed separately (rooted at .local/, .stowrc ignores it in the
# main pass) so stow never sees the top-level bin/ package while placing
# .local/bin/*: GNU Stow 2.4.1 conflates a stowed ~/bin with any package
# subdirectory also named "bin", either erroring or silently linking
# .local/bin/* into ~/bin instead of ~/.local/bin.
if [ -d "$DOTFILES/.local" ]; then
  stow -d "$DOTFILES/.local" -t "$HOME/.local" --adopt .
  chmod +x ~/.local/bin/*
fi
omarchy theme install https://github.com/RyanAHayden/ryha-omarchy-theme

echo "==> sddm theme (omarchy-red)"
sudo cp -rT "$DOTFILES/etc/sddm-themes/omarchy-red" /usr/share/sddm/themes/omarchy-red
sudo cp "$DOTFILES/etc/sddm.conf.d/10-theme.conf" /etc/sddm.conf.d/10-theme.conf

echo "==> sddm greeter screen-off when idle (burn-in protection)"
sudo pacman -S --needed hypridle
sudo install -Dm644 "$DOTFILES/etc/sddm/hyprland.lua" /etc/sddm/hyprland.lua
sudo install -Dm644 "$DOTFILES/etc/sddm/hypridle.conf" /etc/sddm/hypridle.conf
sudo install -Dm644 "$DOTFILES/etc/sddm.conf.d/99-zz-greeter-idle.conf" /etc/sddm.conf.d/99-zz-greeter-idle.conf

echo "==> boot logo (plymouth, via ryha-omarchy theme)"
omarchy plymouth set by theme ryha-omarchy

echo "==> limine boot menu theme"
entries_line=$(sudo grep -n "^/" /boot/limine.conf | head -1 | cut -d: -f1)
sudo bash -c "
  tail -n +$entries_line /boot/limine.conf > /tmp/limine-entries.conf
  cat '$DOTFILES/etc/limine/theme-header.conf' /tmp/limine-entries.conf > /boot/limine.conf
  rm /tmp/limine-entries.conf
"

echo "==> passwordless reboot-to-windows (efibootmgr --bootnext 0001)"
sudo install -m 440 -o root -g root "$DOTFILES/etc/sudoers.d/reboot-to-windows" /etc/sudoers.d/reboot-to-windows

echo "==> xpadneo (BT Xbox-mode driver) + GuliKit rumble block (firmware crashes on rumble)"
yay -S --needed xpadneo-dkms
sudo install -Dm644 "$DOTFILES/etc/modprobe.d/xpadneo.conf" /etc/modprobe.d/xpadneo.conf
sudo install -Dm644 "$DOTFILES/etc/udev/rules.d/99-gulikit-no-ff.rules" /etc/udev/rules.d/99-gulikit-no-ff.rules

echo "Done - check git changes since we adopted your default files"
