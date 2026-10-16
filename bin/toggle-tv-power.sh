#!/usr/bin/env bash
# Turn the TV (HDMI-A-1) output off/on without unplugging it, so the GPU stops driving it.
# tv-off.lua sorts after monitor-mirror.lua, so it overrides the mirror toggle's rule while it exists.
FLAG="$HOME/.local/state/omarchy/toggles/hypr/tv-off.lua"

if [ -f "$FLAG" ]; then
	rm "$FLAG"
	hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = false })' >/dev/null
else
	# mirror = "none": a disabled output that still mirrors DP-1 keeps focus/cursor on itself, so the LG looks frozen.
	echo 'hl.monitor({ output = "HDMI-A-1", disabled = true, mirror = "none" })' >"$FLAG"
fi

hyprctl reload >/dev/null
sleep 0.5
# TV back on in extended mode: it legitimately owns workspace 2, leave it be.
[ ! -f "$FLAG" ] && grep -q 'mirror = "none"' "$(dirname "$FLAG")/monitor-mirror.lua" 2>/dev/null && exit 0
# Workspaces left on the dead TV go back to DP-1.
hyprctl workspaces -j | jq -r '.[] | select(.monitor == "HDMI-A-1" and (.name | startswith("special:") | not)) | .name' |
	while read -r ws; do hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"DP-1\" })" >/dev/null; done
hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-1" })' >/dev/null
