#!/usr/bin/env bash
# Omarchy bar command-module output: bar-status.sh mirror|focus. Prints nothing when there's nothing to show.
case "$1" in
mirror)
	# Live state, not the toggle's flag file: they can disagree (e.g. after a TV replug).
	m=$(hyprctl monitors all -j | jq -r '.[] | select(.name == "HDMI-A-1") | if .disabled then "off" else .mirrorOf end')
	if [ -z "$m" ]; then :
	elif [ "$m" = "off" ]; then echo '{"text":"󰶐","tooltip":"TV output off (right-click to turn on)"}'
	elif [ "$m" = "none" ]; then echo '{"text":"󰍺","tooltip":"TV extended (SUPER+CTRL+M to mirror, right-click to turn off)"}'
	else echo '{"text":"󰍹","tooltip":"TV mirrored (SUPER+CTRL+M to extend, right-click to turn off)"}'
	fi
	;;
focus)
	[ -f "$HOME/.local/state/omarchy/toggles/hypr/focus-lock.lua" ] &&
		echo '{"text":"󰌾","tooltip":"Focus lock on (SUPER+SHIFT+O)","class":"active"}'
	;;
esac
exit 0
