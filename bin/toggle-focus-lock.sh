#!/usr/bin/env bash
# New windows open without stealing focus while this flag file exists.
FLAG_FILE="$HOME/.local/state/omarchy/toggles/hypr/focus-lock.lua"

if [ -f "$FLAG_FILE" ]; then
	rm "$FLAG_FILE"
	omarchy-notification-send -u low "Focus lock off"
else
	mkdir -p "$(dirname "$FLAG_FILE")"
	cat >"$FLAG_FILE" <<'LUA'
hl.window_rule({ match = { class = ".*" }, no_initial_focus = true })
hl.config({ misc = { focus_on_activate = false } })
LUA
	omarchy-notification-send -u low "Focus lock on"
fi

hyprctl reload >/dev/null
