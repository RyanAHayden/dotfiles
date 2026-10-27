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
  The monitor has no 1440x1080 EDID mode, but a custom mode works: see the stretched-res toggle below.

### Stretched res without gamescope (preferred)

Gamescope 3.16.31 kept aborting in The Finals ("CS has been rejected" -> VkResult -4, device lost).
Instead, `SUPER + CTRL + ALT + S` (`~/bin/toggle-stretch-res.sh`) switches DP-1 to a custom
1440x1080@480 mode and the monitor stretches it. Toggle again to go back. It survives `hyprctl reload`.
Set the game to 1440x1080 fullscreen. Or let the launch do it: `/home/ryha/bin/stretch-run mangohud %command%`
(stretched while the game runs, restored on exit/crash). Cap: see below.
Add `PROTON_USE_XALIA=0` in front to turn off Xalia, Proton's controller helper for launchers (The Finals doesn't need it, and it uses ~4% CPU):
`PROTON_USE_XALIA=0 /home/ryha/bin/stretch-run mangohud %command%`. Check with `pgrep xalia` (should print nothing).
The LG must be in 1080p@480 dual mode first. That can't be automated: DDC VCP `F8` reads the mode
(00 = 4K@240, 01 = 1080p@480) but the monitor rejects writes to it.

### FPS cap (RTSS equivalent)

`~/bin/fps-cap.sh` writes `~/.config/MangoHud/MangoHud.conf` (edit the script, not the conf) and reloads running
games live over MangoHud's control socket. Applies to games launched with `mangohud %command%`. Overlay hidden by default; Shift+F6 (also a Hyprland bind) shows/hides it and the choice survives cap changes.
Needs `omarchy pkg add mangohud`.

| Key | Cap |
|---|---|
| Shift+F1 | 165 / 185 |
| Shift+F2 | 200 / 225 |
| Shift+F3 | 300 / 340 |
| Shift+F4 | 400 / 480 |
| Shift+F5 | uncapped |
| Shift+F7 | 500 / 525 / 550 / 600 / 700 |

Each key cycles through its values. Pressed in a game, the cap is remembered for that game (in `~/.local/state/fps-cap/caps`)
and reapplied whenever the game gets focus; pressed outside a game it sets the default, used by games with no
saved cap. Don't use MangoHud per-app confs: a running game never switches to one, and they shadow MangoHud.conf. MangoHud's own Shift+F1/F2/F4/F12 shortcuts are moved off those keys
because it polls keys directly and would fire alongside the Hyprland binds.

- Uses `late` (waits before the game reads input, so no stale frames / lowest latency). `early` gives flatter
  frametimes but input up to 1 frame older (~4.4ms at 225). Change `fps_limit_method` in `bin/fps-cap.sh`.
- Cap below where the GPU hits ~95%. A GPU-bound game queues frames: latency spikes and pacing goes uneven with any limiter.
- No-install option: `DXVK_FRAME_RATE=225` (DX9-11) / `VKD3D_FRAME_RATE=225` (DX12) before `%command%`.
