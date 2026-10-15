#!/usr/bin/env bash
# Turn the TV (HDMI-A-1) output off/on without unplugging it, so the GPU stops driving it.
# tv-off.lua sorts after monitor-mirror.lua, so it overrides the mirror toggle's rule while it exists.
FLAG="$HOME/.local/state/omarchy/toggles/hypr/tv-off.lua"

if [ -f "$FLAG" ]; then
	rm "$FLAG"
	hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = false })' >/dev/null
else
	echo 'hl.monitor({ output = "HDMI-A-1", disabled = true })' >"$FLAG"
fi

hyprctl reload >/dev/null
