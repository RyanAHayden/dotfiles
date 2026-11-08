#!/bin/bash
# Deploys the sddm theme, boot logo, and limine theme onto the live system.
# Safe to re-run any time (e.g. after `omarchy refresh sddm`/`omarchy refresh limine`).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> dotfiles setup"

command -v stow >/dev/null || sudo pacman -S stow
cd "$DOTFILES"
# stow --adopt replaces repo files with ones already on the machine; compare tracked changes before and after so
# the end can list just those (not edits that were already there)
changed() { git -C "$DOTFILES" status --porcelain -z --untracked-files=no | while IFS= read -r -d "" e; do echo "$(git -C "$DOTFILES" hash-object "${e:3}" 2>/dev/null) ${e:3}"; done; }
before=$(changed)
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
adopted=$(comm -13 <(sort <<<"$before") <(changed | sort) | cut -d' ' -f2-)
omarchy theme install https://github.com/RyanAHayden/ryha-omarchy-theme

echo "==> Zen (github.com/RyanAHayden/zen, shared with hypr-mac)"
[ -d ~/zen ] || git clone -q https://github.com/RyanAHayden/zen ~/zen
~/zen/setup.sh

echo "==> Vencord (github.com/RyanAHayden/vencord, shared with hypr-mac)"
# it also patches Vencord into Discord, which Discord updates undo: re-run ~/vencord/setup.sh after one
[ -d ~/vencord ] || git clone -q https://github.com/RyanAHayden/vencord ~/vencord
~/vencord/setup.sh

echo "==> nvim config (github.com/RyanAHayden/nvim, shared with hypr-mac)"
[ -d ~/nvim ] || git clone -q https://github.com/RyanAHayden/nvim ~/nvim
~/nvim/setup.sh

echo "==> Obsidian (github.com/RyanAHayden/obsidian, shared with hypr-mac)"
# also re-run it if a phone switches vim mode off in the synced vault
[ -d ~/obsidian ] || git clone -q https://github.com/RyanAHayden/obsidian ~/obsidian
~/obsidian/setup.sh

echo "==> dolphin as file manager (hypr binds in .config/hypr/bindings.lua)"
sudo pacman -S --needed dolphin
xdg-mime default org.kde.dolphin.desktop inode/directory
# dolphin defaults to konsole for Terminal=true apps (nvim.desktop etc.)
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication xdg-terminal-exec
kwriteconfig6 --file kdeglobals --group General --key TerminalService foot.desktop
# no "execute this file?" prompt (run scripts); KDE sounds muted via stowed .config/plasma_workspace.notifyrc
kwriteconfig6 --file kiorc --group "Executable scripts" --key behaviourOnLaunch execute
# archives open as browsable folders in dolphin (bin/dolphin-archive); KDE file picker via portal
sudo pacman -S --needed kio-extras xdg-desktop-portal-kde
for m in $(sed -n 's/^MimeType=//p' "$DOTFILES/.local/share/applications/dolphin-archive.desktop" | tr ';' ' '); do
  xdg-mime default dolphin-archive.desktop "$m"
done

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

echo "==> passwordless GPU max-clock toggle (bin/toggle-gpu-high.sh)"
sudo install -m 440 -o root -g root "$DOTFILES/etc/sudoers.d/gpu-high" /etc/sudoers.d/gpu-high

echo "==> xpadneo (BT Xbox-mode driver) + GuliKit rumble block (firmware crashes on rumble)"
yay -S --needed xpadneo-dkms
sudo install -Dm644 "$DOTFILES/etc/modprobe.d/xpadneo.conf" /etc/modprobe.d/xpadneo.conf
sudo install -Dm644 "$DOTFILES/etc/udev/rules.d/99-gulikit-no-ff.rules" /etc/udev/rules.d/99-gulikit-no-ff.rules

echo "==> reserve Sunshine ports from ephemeral range (avoids bind EADDRINUSE crash loop)"
sudo install -Dm644 "$DOTFILES/etc/sysctl.d/90-sunshine-ports.conf" /etc/sysctl.d/90-sunshine-ports.conf
sudo sysctl -p /etc/sysctl.d/90-sunshine-ports.conf

if [ -n "$adopted" ]; then
  echo
  echo "==> stow pulled these existing files into $DOTFILES (yours replaced the repo's, see git diff):"
  sed 's/^/  /' <<<"$adopted"
  echo "  keep the repo's: git -C $DOTFILES checkout --$(while read -r f; do printf ' %q' "$f"; done <<<"$adopted")"
fi
echo "Done."
