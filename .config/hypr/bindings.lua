-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Quadrant tile toggle (no borders, no waybar, no transparency)
hl.unbind("SUPER + ALT + G") -- was: Move active window out of group
o.bind("SUPER + ALT + G", "Toggle quadrant tile mode", "~/.config/hypr/scripts/quadrant-tile.sh")

-- Unbind defaults that conflict with vim-key focus/move bindings below
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

-- Unused (desktop, no laptop display/touchpad hardware)
hl.unbind("SUPER + CTRL + Delete")
hl.unbind("SUPER + CTRL + ALT + Delete")
hl.unbind("XF86TouchpadToggle")
hl.unbind("XF86TouchpadOff")
hl.unbind("XF86TouchpadOn")
hl.unbind("XF86KbdLightOnOff")

-- Applications (unbind the default assigned to each key first)
o.bind(
	"SUPER + ALT + RETURN",
	"Tmux",
	'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" bash -c "tmux"'
)

hl.unbind("SUPER + SHIFT + RETURN") -- was: Browser
o.bind("SUPER + SHIFT + RETURN", "Browser (Blank window)", "omarchy-launch-browser --blank-window")

o.bind(
	"SUPER + ALT + SHIFT + F",
	"File manager (cwd)",
	'uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"'
)
o.bind("SUPER + SHIFT + B", "Browser", "zen-browser")
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")
o.bind("SUPER + SHIFT + M", "Music", "spotify")

hl.unbind("SUPER + SHIFT + C") -- was: Calendar
o.bind("SUPER + SHIFT + C", "Discord", "omarchy-launch-or-focus discord")

hl.unbind("SUPER + SHIFT + G") -- was: Signal
o.bind("SUPER + SHIFT + G", "Steam", "omarchy-launch-or-focus steam")

hl.unbind("SUPER + SHIFT + SLASH") -- was: 1Password
o.bind("SUPER + SHIFT + SLASH", "Passwords", 'omarchy-launch-or-focus keepassxc "uwsm-app -- keepassxc"')

hl.unbind("SUPER + SHIFT + S") -- was: Google Maps
o.bind("SUPER + SHIFT + S", "Audio", "uwsm-app -- xdg-terminal-exec -- wiremix")

-- Restore pre-Quattro TUI managers instead of the built-in shell panels
hl.unbind("SUPER + CTRL + B") -- was: Bluetooth panel (omarchy.bluetooth)
o.bind("SUPER + CTRL + B", "Bluetooth (bluetui)", "uwsm-app -- xdg-terminal-exec -- bluetui")

-- hl.unbind("SUPER + CTRL + A") -- was: Audio panel (omarchy.audio)

-- Brightness controls
o.bind("F23", "Brightness down 5%", "/home/ryha/dotfiles/bin/omarchy-brightness-display -5")
o.bind("F24", "Brightness up 5%", "/home/ryha/dotfiles/bin/omarchy-brightness-display +5")
o.bind("SHIFT + F23", "Brightness down 25%", "/home/ryha/dotfiles/bin/omarchy-brightness-display -25")
o.bind("SHIFT + F24", "Brightness up 25%", "/home/ryha/dotfiles/bin/omarchy-brightness-display +25")

-- Crosshair
o.bind(
	"F19",
	"Show green crosshair",
	"pkill crosshair; /home/ryha/.local/bin/crosshair/crosshair --image /home/ryha/.local/bin/crosshair/cross.png --gamma 1"
)
o.bind(
	"XF86Launch9",
	"Show dot crosshair",
	"pkill crosshair; /home/ryha/.local/bin/crosshair/crosshair --image /home/ryha/.local/bin/crosshair/dot.png --gamma 1"
)
o.bind("XF86Tools", "Kill crosshair", "pkill crosshair")

-- Show keybindings on I instead of the now-repurposed K
o.bind("SUPER + I", "Show key bindings", "omarchy-menu-keybindings")

-- Window focus (vim keys)
o.bind("SUPER + backslash", "Toggle split direction", hl.dsp.layout("togglesplit"))
o.bind("SUPER + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Move focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Move focus right", hl.dsp.focus({ direction = "r" }))

-- Move window (vim keys)
o.bind("SUPER + SHIFT + H", "Move Window Left", hl.dsp.window.move({ direction = "left" }))
o.bind("SUPER + SHIFT + J", "Move Window Down", hl.dsp.window.move({ direction = "down" }))
o.bind("SUPER + SHIFT + K", "Move Window Up", hl.dsp.window.move({ direction = "up" }))
o.bind("SUPER + SHIFT + L", "Move Window Right", hl.dsp.window.move({ direction = "right" }))

-- Dwindle: make focused window the big one (inserts it at the root, unlike swap)
o.bind("SUPER + SHIFT + I", "Promote window", hl.dsp.layout("movetoroot"))
-- Dwindle: flip which side of the split the big window is on (left/right)
o.bind("SUPER + CTRL + SHIFT + I", "Flip split side", hl.dsp.layout("swapsplit"))

-- Workspace navigation (relative, wraps past existing workspaces)
o.bind("SUPER + A", "Switch workspace left", hl.dsp.focus({ workspace = "r-1" }))
o.bind("SUPER + D", "Switch workspace right", hl.dsp.focus({ workspace = "r+1" }))

hl.unbind("SUPER + SHIFT + A") -- was: ChatGPT
o.bind("SUPER + SHIFT + A", "Move window workspace left", hl.dsp.window.move({ workspace = "r-1" }))

hl.unbind("SUPER + SHIFT + D") -- was: Docker
o.bind("SUPER + SHIFT + D", "Move window workspace right", hl.dsp.window.move({ workspace = "r+1" }))
