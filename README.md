# My Omarchy Dotfiles

Use at your own risk.

## Setup

`./setup.sh` - safe to re-run (e.g. after `omarchy refresh sddm` / `omarchy refresh limine`). It:

- stows everything with `--adopt`, so existing files get pulled in and show up as git changes to keep or discard
- installs the [ryha-omarchy theme](https://github.com/RyanAHayden/ryha-omarchy-theme), its plymouth boot logo, the limine boot menu theme and the sddm theme (+ greeter screen-off when idle)
- sets up LibreWolf from [librewolf](https://github.com/RyanAHayden/librewolf) (cloned to `~/librewolf`), the same prefs and extensions hypr-mac uses
- sets dolphin as the file manager (archives open as folders, scripts run without a prompt)
- installs sudoers rules for `reboot-to-windows` and `toggle-gpu-high.sh`
- installs xpadneo and blocks rumble on GuliKit pads (their firmware crashes on it)
- reserves the Sunshine ports from the ephemeral range (avoids a bind EADDRINUSE crash loop)

Extra packages: `omarchy pkg add bluetui wiremix mangohud`

Discord theme (Vencord):
`https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-auto.theme.css`

### sddm password at login (advanced)

`./etc/setup-login-password.sh` - run this yourself after the disk-encryption/TPM2/secure-boot
setup (see `etc/initcpio/README.md`). That setup removes the LUKS passphrase prompt, so this makes
sure sddm still asks for a password instead of autologging in.

## Remote access

### Sunshine (connect with Moonlight)

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

### Wake from sleep over Tailscale (`wake-pc`)

A sleeping PC isn't on Tailscale, so an always-on box on the same LAN (e.g. the NAS) sends the
Wake-on-LAN packet for you over SSH. The relay only needs `python3`; nothing is installed on it.

On the PC to be woken (once; NetworkManager keeps it):

```
nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic
nmcli device reapply <wired iface>
```

If it still won't wake, enable "Wake on LAN" / "Power On by PCI-E" in the BIOS and turn off ErP.
Suspend (`systemctl suspend`) only - WoL doesn't work from a full shutdown here.

On the machine doing the waking (any with bash + ssh, e.g. a laptop), copy
[`.config/wake-pc.conf.example`](.config/wake-pc.conf.example) to `~/.config/wake-pc.conf`,
fill it in, then run `wake-pc`. From a phone, SSH to the relay and send the packet from there.

## Gaming

### Stretched res

`SUPER + CTRL + ALT + S` (`~/bin/toggle-stretch-res.sh`) switches DP-1 to a custom
1440x1080@480 mode and the monitor stretches it. Toggle again to go back. It survives `hyprctl reload`.
Set the game to 1440x1080 fullscreen.

Or let the launch do it (stretched while the game runs, restored on exit/crash):
`PROTON_USE_XALIA=0 /home/ryha/bin/stretch-run mangohud %command%`.
`PROTON_USE_XALIA=0` turns off Xalia, Proton's controller helper for launchers (uses ~4% CPU,
most games don't need it). Check with `pgrep xalia` (should print nothing).

The LG must be in 1080p@480 dual mode first. That can't be automated: DDC VCP `F8` reads the mode
(00 = 4K@240, 01 = 1080p@480) but the monitor rejects writes to it.

### FPS cap (RTSS equivalent)

`~/bin/fps-cap.sh` writes `~/.config/MangoHud/MangoHud.conf` (edit the script, not the conf) and reloads running
games live over MangoHud's control socket. Applies to games launched with `mangohud %command%`.
Overlay hidden by default; Shift+F6 (also a Hyprland bind) shows/hides it and the choice survives cap changes.

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
saved cap. Don't use MangoHud per-app confs: a running game never switches to one, and they shadow MangoHud.conf.
MangoHud's own Shift+F1/F2/F4/F12 shortcuts are moved off those keys because it polls keys directly and would
fire alongside the Hyprland binds.

- Uses `late` (waits before the game reads input, so no stale frames / lowest latency). `early` gives flatter
  frametimes but input up to 1 frame older (~4.4ms at 225). Change `fps_limit_method` in `bin/fps-cap.sh`.
- Cap below where the GPU hits ~95%. A GPU-bound game queues frames: latency spikes and pacing goes uneven with any limiter.
- No-install option: `DXVK_FRAME_RATE=225` (DX9-11) / `VKD3D_FRAME_RATE=225` (DX12) before `%command%`.
