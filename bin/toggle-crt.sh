#!/usr/bin/env bash
STATE_FILE="$HOME/.local/state/crt-shader-enabled"

if [ -f "$STATE_FILE" ]; then
	rm "$STATE_FILE"
else
	touch "$STATE_FILE"
fi

hyprctl reload
