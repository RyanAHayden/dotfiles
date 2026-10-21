# My Omarchy Dotfiles

Use at your own risk
`./setup.sh` - stows using --adopt so you can see git changes before discarding what you want to change. It also installs theme and sets boot logo and limine

## Install extra packages

`omarchy pkg add bluetui wiremix`

## Remote desktop: Sunshine (connect with Moonlight)

`omarchy install service sunshine` - installs it, opens ports for LAN + Tailscale,
adds the "Sunshine Admin" web app. If it dies at "Refusing to operate on linked
unit file", finish with `systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service`
then re-run the ufw/webapp steps from `$(which omarchy-install-service-sunshine)`.
Don't keep its `o.launch_on_start("sunshine")` line - the systemd unit already starts it.
Add `capture = kms` to `~/.config/sunshine/sunshine.conf` - otherwise it falls back to the
screen-share portal and pops an output picker on every start ("Failed to gain CAP_SYS_ADMIN" is harmless).

First run: open Sunshine Admin (https://localhost:47990), set a username/password,
then pair Moonlight with the PIN it shows. Over Tailscale add the host as `omarchy-desktop`.
For phone use: in Sunshine Admin > Applications, set an app's prep command to
`~/bin/zoom 2` (undo: `~/bin/zoom reset`). Super+scroll zooms at the desk.

Theme:
`https://github.com/RyanAHayden/ryha-omarchy-theme`

## sddm theme, boot logo, limine theme

`./setup.sh` (redeploys all three`omarchy refresh sddm`/`omarchy refresh limine`)

## sddm password at login (advanced)

`./etc/setup-login-password.sh` - run this yourself after your
disk-encryption/TPM2/secure-boot setup (see `etc/initcpio/README.md`).
That setup removes the LUKS passphrase prompt, so this makes sure sddm
still asks for a password instead of autologging in.

Discord Theme (Vencord):
`https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-auto.theme.css`

## Stretched res in games (gamescope)

Steam > game > Properties > Launch Options:

```
gamescope -w 1440 -h 1080 -W 1920 -H 1080 -S stretch -f -r 480 --backend sdl --force-grab-cursor -- %command%
```

- `--backend sdl`: gamescope 3.16's default wayland backend never maps a window under Hyprland (game runs, nothing shows).
- `--force-grab-cursor`: otherwise the mouse isn't captured.
- `-r 480`: match the monitor refresh or gamescope caps lower.
- Run `sudo setcap 'CAP_SYS_NICE=eip' $(which gamescope)` (setup.sh does it). Without it gamescope
  logs "No CAP_SYS_NICE ... Performance will be affected" and fps drops. A gamescope update wipes it, so re-run.
- Nested gamescope still costs some fps. If that's too much, play native 1920x1080 with the in-game upscaler.
  The monitor can't do 1440x1080, so gamescope is the only way to stretch.
