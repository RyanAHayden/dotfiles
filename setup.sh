#!/bin/bash
# Deploys the sddm theme, boot logo, and limine theme onto the live system.
# Safe to re-run any time (e.g. after `omarchy refresh sddm`/`omarchy refresh limine`).
set -euo pipefail

# runs as you (it sudo's the system steps itself). Not re-exec'd as $SUDO_USER: sudo already dropped the desktop
# session's env (OMARCHY_PATH, WAYLAND_DISPLAY, DBUS), so `omarchy theme set` half-applies (no bar/border/nvim theme)
if [ "$EUID" -eq 0 ]; then
  echo "run without sudo: ./setup.sh (it asks for your password when it needs it)" >&2
  exit 1
fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> dotfiles setup"

# Unattended: the password is the only question, asked once here; sudo is kept fresh until the script exits.
# Logins (gh, Tailscale) are skipped and listed at the end instead; git never stops to ask for credentials.
sudo -v
while sleep 60; do sudo -n true; kill -0 $$ 2>/dev/null || exit; done 2>/dev/null &
export GIT_TERMINAL_PROMPT=0
later=() # what's left for you, printed at the end

command -v stow >/dev/null || sudo pacman -S --needed --noconfirm stow
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
  # the repo's scripts, not ~/.local/bin/* (other installers drop links there, e.g. superwhisper -> /usr/bin)
  chmod +x "$DOTFILES"/.local/bin/*
fi
adopted=$(comm -13 <(sort <<<"$before") <(changed | sort) | cut -d' ' -f2-)
omarchy theme install https://github.com/RyanAHayden/ryha-omarchy-theme

echo "==> remove Omarchy's preinstalled web apps (first run only, so ones added later stay)"
first_run_done="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/webapps-removed"
if [ ! -e "$first_run_done" ]; then
  omarchy webapp remove all
  mkdir -p "$(dirname "$first_run_done")" && touch "$first_run_done"
fi

echo "==> git uses the gh login (push credentials + commit name/email)"
if gh auth status >/dev/null 2>&1; then
  # plain `gh`, not `gh auth setup-git`, which writes mise's version-pinned path and breaks on the next gh upgrade
  for host in https://github.com https://gist.github.com; do
    git config --global --replace-all "credential.$host.helper" ""
    git config --global --add "credential.$host.helper" "!gh auth git-credential"
  done
  # GitHub noreply address, so commits link to the account without exposing a real email
  git config --global user.name "$(gh api user --jq '.name // .login')"
  git config --global user.email "$(gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"')"
else
  echo "    not logged in, skipped"
  later+=("GitHub: gh auth login, then re-run ./setup.sh (sets git's credential helper, name and email)")
fi

echo "==> apps the keybindings launch (.config/hypr/bindings.lua)"
# keepassxc SUPER+SHIFT+/, wiremix SUPER+CTRL+A (dolphin is with its config below)
# qt5-wayland: KeePassXC is Qt5, and without it falls back to XWayland: unscaled on a HiDPI panel, and class
# KeePassXC instead of org.keepassxc.KeePassXC (misses the scratchpad rule)
sudo pacman -S --needed --noconfirm keepassxc qt5-wayland wiremix
# Discord SUPER+SHIFT+C, Spotify SUPER+SHIFT+M: neither ships an ARM Linux client, so web apps there
# (the bindings and scratchpad rules match either window)
if omarchy-hw-x86; then
  omarchy pkg add discord spotify
else
  apps=~/.local/share/applications
  [ -f "$apps/Discord.desktop" ] || omarchy-webapp-install Discord https://discord.com/channels/@me \
    https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/discord.png
  [ -f "$apps/Spotify.desktop" ] || omarchy-webapp-install Spotify https://open.spotify.com/ \
    https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/spotify.png
fi
# Steam SUPER+SHIFT+G (Omarchy's installer picks the GPU's lib32 drivers first; it starts Steam once when done)
command -v steam >/dev/null || omarchy install gaming steam

echo "==> Syncthing (Arch's user unit: starts at login, no browser page)"
# an old dotfiles override (removed) bound it to a mount that never exists, so it never ran; drop its stow link
[ -L ~/.config/systemd/user/syncthing.service ] && [ ! -e ~/.config/systemd/user/syncthing.service ] && rm ~/.config/systemd/user/syncthing.service
sudo pacman -S --needed --noconfirm syncthing
systemctl --user daemon-reload
systemctl --user enable --now syncthing.service

echo "==> Tailscale (installed and started here; login is left for later)"
sudo pacman -S --needed --noconfirm tailscale
sudo systemctl enable --now tailscaled.service
if ! tailscale status >/dev/null 2>&1; then
  # Omarchy's installer re-checks the package/service, then logs in, makes you operator, sets up Taildrop + web app
  later+=("Tailscale: omarchy install service tailscale (opens a login link)")
fi

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
sudo pacman -S --needed --noconfirm dolphin
xdg-mime default org.kde.dolphin.desktop inode/directory
# dolphin defaults to konsole for Terminal=true apps (nvim.desktop etc.)
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication xdg-terminal-exec
kwriteconfig6 --file kdeglobals --group General --key TerminalService foot.desktop
# no "execute this file?" prompt (run scripts); KDE sounds muted via stowed .config/plasma_workspace.notifyrc
kwriteconfig6 --file kiorc --group "Executable scripts" --key behaviourOnLaunch execute
# archives open as browsable folders in dolphin (bin/dolphin-archive); KDE file picker via portal
sudo pacman -S --needed --noconfirm kio-extras xdg-desktop-portal-kde
for m in $(sed -n 's/^MimeType=//p' "$DOTFILES/.local/share/applications/dolphin-archive.desktop" | tr ';' ' '); do
  xdg-mime default dolphin-archive.desktop "$m"
done

echo "==> sddm theme (omarchy-red)"
sudo cp -rT "$DOTFILES/etc/sddm-themes/omarchy-red" /usr/share/sddm/themes/omarchy-red
sudo cp "$DOTFILES/etc/sddm.conf.d/10-theme.conf" /etc/sddm.conf.d/10-theme.conf

echo "==> sddm greeter idle: screen off at 5 min (burn-in protection), laptop on battery suspends at 15"
sudo pacman -S --needed --noconfirm hypridle
sudo install -Dm644 "$DOTFILES/etc/sddm/hyprland.lua" /etc/sddm/hyprland.lua
sudo install -Dm644 "$DOTFILES/etc/sddm/hypridle.conf" /etc/sddm/hypridle.conf
sudo install -Dm755 "$DOTFILES/etc/sddm/idle-suspend" /etc/sddm/idle-suspend
sudo install -Dm644 "$DOTFILES/etc/sddm.conf.d/99-zz-greeter-idle.conf" /etc/sddm.conf.d/99-zz-greeter-idle.conf

echo "==> boot logo (plymouth, via ryha-omarchy theme)"
omarchy plymouth set by theme ryha-omarchy

# Only where Limine boots the machine: the M3 boots m1n1 -> U-Boot with no /boot/limine.conf, and the grep failing
# there stopped setup (set -e) before everything below it
if sudo test -f /boot/limine.conf; then
  echo "==> limine boot menu theme"
  entries_line=$(sudo grep -n "^/" /boot/limine.conf | head -1 | cut -d: -f1)
  sudo bash -c "
    tail -n +$entries_line /boot/limine.conf > /tmp/limine-entries.conf
    cat '$DOTFILES/etc/limine/theme-header.conf' /tmp/limine-entries.conf > /boot/limine.conf
    rm /tmp/limine-entries.conf
  "
fi

if ! omarchy-hw-laptop; then # desktop only (laptop mode, as in .config/hypr/laptop.lua)
  echo "==> passwordless reboot-to-windows (efibootmgr --bootnext 0001)"
  sudo install -m 440 -o root -g root "$DOTFILES/etc/sudoers.d/reboot-to-windows" /etc/sudoers.d/reboot-to-windows
fi

echo "==> passwordless GPU max-clock toggle (bin/toggle-gpu-high.sh)"
sudo install -m 440 -o root -g root "$DOTFILES/etc/sudoers.d/gpu-high" /etc/sudoers.d/gpu-high

echo "==> laptop keys: Caps = Ctrl, Fn + hjkl = arrows (keyd; on by default on laptops, toggle with bin/laptop-keys or SUPER+CTRL+ALT+K)"
sudo pacman -S --needed --noconfirm keyd
sudo install -Dm644 "$DOTFILES/etc/keyd/default.conf" /etc/keyd/default.conf
sudo install -m 440 -o root -g root "$DOTFILES/etc/sudoers.d/laptop-keys" /etc/sudoers.d/laptop-keys
# laptop mode: on by default (first run only, so turning it off with laptop-keys sticks); desktop stays off
laptop_keys_done="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/laptop-keys-enabled"
if omarchy-hw-laptop && [ ! -e "$laptop_keys_done" ]; then
  sudo systemctl enable --now keyd
  mkdir -p "$(dirname "$laptop_keys_done")" && touch "$laptop_keys_done"
fi
# pick up a changed config if it's already on
systemctl is-active --quiet keyd && sudo keyd reload

echo "==> xpadneo (BT Xbox-mode driver) + GuliKit rumble block (firmware crashes on rumble)"
yay -S --needed --noconfirm --answerclean None --answerdiff None xpadneo-dkms
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
if ((${#later[@]})); then
  echo
  echo "==> left for you:"
  printf '  - %s\n' "${later[@]}"
fi
echo "Done."
