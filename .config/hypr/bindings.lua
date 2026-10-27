-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Quadrant tile toggle (no borders, no waybar, no transparency)
hl.unbind("SUPER + ALT + G") -- was: Move active window out of group
o.bind("SUPER + ALT + G", "Toggle quadrant tile mode", "~/bin/quadrant-tile.sh")

-- Unbind defaults that conflict with vim-key focus/move bindings below
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

-- Force kill active window (SIGKILL, works on frozen apps)
hl.unbind("SUPER + SHIFT + W") -- was: Omawrite
o.bind("SUPER + SHIFT + W", "Force kill window", hl.dsp.window.kill())

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

hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + ALT + SPACE", "Dictate", "voxtype record toggle")

hl.unbind("SUPER + SHIFT + RETURN") -- was: Browser
o.bind("SUPER + SHIFT + RETURN", "Browser (Blank window)", "omarchy-launch-browser --blank-window")

o.bind(
	"SUPER + ALT + SHIFT + F",
	"File manager (cwd)",
	'uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"'
)
hl.unbind("SUPER + SHIFT + B") -- was: Browser
o.bind("SUPER + SHIFT + B", "Browser", "omarchy-launch-browser")

hl.unbind("SUPER + SHIFT + ALT + B") -- was: Browser (private)
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")
o.bind("SUPER + SHIFT + M", "Spotify (scratchpad)", "~/bin/scratch-app Spotify spotify")

hl.unbind("SUPER + SHIFT + C") -- was: Calendar
o.bind("SUPER + SHIFT + C", "Discord (scratchpad)", "~/bin/scratch-app discord discord")

hl.unbind("SUPER + SHIFT + G") -- was: Signal
o.bind("SUPER + SHIFT + G", "Steam", "omarchy-launch-or-focus steam")

hl.unbind("SUPER + SHIFT + SLASH") -- was: 1Password
o.bind("SUPER + SHIFT + SLASH", "Passwords (scratchpad)", "~/bin/scratch-app org.keepassxc.KeePassXC keepassxc")

hl.unbind("SUPER + SHIFT + S") -- was: Google Maps
o.bind("SUPER + SHIFT + S", "Audio", "uwsm-app -- xdg-terminal-exec --app-id=wiremix -- wiremix")

hl.unbind("SUPER + SHIFT + P") -- was: Google Photos

-- Restore pre-Quattro TUI managers instead of the built-in shell panels
hl.unbind("SUPER + CTRL + B") -- was: Bluetooth panel (omarchy.bluetooth)
o.bind("SUPER + CTRL + B", "Bluetooth (bluetui)", "uwsm-app -- xdg-terminal-exec --app-id=bluetui -- bluetui")

hl.unbind("SUPER + CTRL + A") -- was: Audio panel (omarchy.audio)
-- o.bind("SUPER + CTRL + A", "Audio (wiremix)", "uwsm-app -- xdg-terminal-exec --app-id=wiremix -- wiremix")

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

-- Toggle HDMI-A-1 mirroring DP-1 (built-in mirror toggle only covers laptop panels)
o.bind("SUPER + CTRL + M", "Toggle monitor mirror", "~/bin/toggle-monitor-mirror.sh")
-- Turn the TV output off/on without unplugging (also right-click the bar's TV icon)
hl.unbind("SUPER + CTRL + O") -- was: Omarchy toggle menu
o.bind("SUPER + CTRL + O", "Toggle TV output", "~/bin/toggle-tv-power.sh")
-- Stretched 1440x1080 on DP-1 for games (replaces gamescope, which kept losing the GPU)
o.bind("SUPER + CTRL + ALT + S", "Toggle stretched res", "~/bin/toggle-stretch-res.sh")
-- MangoHud frame cap, live in-game (each key flips between its two values)
o.bind("SHIFT + F1", "Frame cap 165/185", "~/bin/fps-cap.sh 165 185")
o.bind("SHIFT + F2", "Frame cap 200/225", "~/bin/fps-cap.sh 200 225")
o.bind("SHIFT + F3", "Frame cap 300/340", "~/bin/fps-cap.sh 300 340")
o.bind("SHIFT + F4", "Frame cap 400/480", "~/bin/fps-cap.sh 400 480")
o.bind("SHIFT + F5", "Frame cap off", "~/bin/fps-cap.sh 0")
o.bind("SHIFT + F6", "Toggle MangoHud overlay", "~/bin/fps-cap.sh hud")
o.bind("SHIFT + F7", "Frame cap 500/525/550/600/700", "~/bin/fps-cap.sh 500 525 550 600 700")

-- Focus lock: new windows open without stealing focus
hl.unbind("SUPER + SHIFT + O") -- was: Obsidian
o.bind("SUPER + SHIFT + O", "Toggle focus lock", "~/bin/toggle-focus-lock.sh")

-- Window opacity steps (SUPER + BACKSPACE still toggles fully opaque, which overrides these)
o.bind("SUPER + ALT + BACKSPACE", "More window transparency", "~/bin/window-opacity.sh -0.05")
o.bind("SUPER + SHIFT + ALT + BACKSPACE", "Less window transparency", "~/bin/window-opacity.sh +0.05")

-- Per-window volume for the window under the cursor
o.bind("SUPER + SHIFT + mouse_up", "Window volume up", "~/bin/window-volume.sh +5%")
o.bind("SUPER + SHIFT + mouse_down", "Window volume down", "~/bin/window-volume.sh -5%")
o.bind("SUPER + SHIFT + mouse:273", "Toggle window mute", "~/bin/window-volume.sh mute")

-- SUPER + scroll zooms the screen around the cursor instead of switching workspaces
hl.unbind("SUPER + CTRL + Z")
hl.unbind("SUPER + CTRL + ALT + Z")
hl.unbind("SUPER + mouse_down") -- was: Scroll active workspace forward
hl.unbind("SUPER + mouse_up") -- was: Scroll active workspace backward
o.bind("SUPER + mouse_up", "Zoom in", "~/bin/zoom in")
o.bind("SUPER + mouse_down", "Zoom out", "~/bin/zoom out")

-- SUPER + ALT + scroll adjusts display brightness (replaces group next/prev)
hl.unbind("SUPER + ALT + mouse_down") -- was: Next window in group
hl.unbind("SUPER + ALT + mouse_up") -- was: Previous window in group
o.bind("SUPER + ALT + mouse_up", "Brightness up 5%", "/home/ryha/dotfiles/bin/omarchy-brightness-display +5")
o.bind("SUPER + ALT + mouse_down", "Brightness down 5%", "/home/ryha/dotfiles/bin/omarchy-brightness-display -5")

-- Toggle DP-1 pin: press, switch LG dual mode (4K@240 <-> 1080p@480), press again
o.bind("SUPER + CTRL + ALT + O", "Toggle monitor pin (dual-mode switch)", "~/bin/pin-monitors-toggle")

-- Toggle labels (title · program · pid) over every visible window (local.window-labels shell plugin)
o.bind("SUPER + ALT + W", "Toggle window labels", "omarchy-shell windowlabels toggle")

-- Recent-window Super+Tab with live previews (from github.com/ilsmith0421/dotfiles).
-- Freezes MRU order while Super is held; commits on Super release.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
o.bind("SUPER + TAB", "Switch to recent window", "$HOME/.local/bin/recent-window-switcher next")
o.bind("SUPER + SHIFT + TAB", "Switch backward through recent windows", "$HOME/.local/bin/recent-window-switcher back")
o.bind(
	"SUPER + SUPER_L",
	nil,
	"$HOME/.local/bin/recent-window-switcher release",
	{ release = true, ignore_mods = true, non_consuming = true, transparent = true }
)
o.bind(
	"SUPER + SUPER_R",
	nil,
	"$HOME/.local/bin/recent-window-switcher release",
	{ release = true, ignore_mods = true, non_consuming = true, transparent = true }
)
