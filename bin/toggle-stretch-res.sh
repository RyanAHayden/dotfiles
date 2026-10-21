#!/usr/bin/env bash
# Stretched res for games without gamescope: DP-1 runs a custom 1440x1080 mode and the
# monitor's scaler stretches it. Persists through reloads while the flag file exists.
# Frame cap lives in ~/.config/MangoHud/MangoHud.conf (launch games with: mangohud %command%).
MODE="1440x1080@480"
FLAG_FILE="$HOME/.local/state/omarchy/toggles/hypr/stretch-res.lua"

if [ -f "$FLAG_FILE" ]; then
	rm "$FLAG_FILE"
	omarchy-notification-send -u low "Stretched res off"
else
	mkdir -p "$(dirname "$FLAG_FILE")"
	printf 'hl.monitor({ output = "DP-1", mode = "%s", position = "0x0", scale = 1 })\n' "$MODE" >"$FLAG_FILE"
	omarchy-notification-send -u low "Stretched res on ($MODE)"
fi

hyprctl reload >/dev/null
