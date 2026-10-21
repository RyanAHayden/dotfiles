#!/usr/bin/env bash
# Omarchy bar command-module output: bar-status.sh mirror|focus|pin|awake. Prints nothing when there's nothing to show.
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
pin)
	systemctl is-active -q pin-monitors &&
		echo '{"text":"󰐃","tooltip":"Monitor pinned (click or SUPER+CTRL+ALT+O to unpin for a dual-mode switch)"}'
	;;
awake)
	# Only the controller's hold; a manual stay-awake shows on Omarchy's own indicator.
	[ "$(cat "$HOME/.local/state/omarchy/indicators/stay-awake" 2>/dev/null)" = gamepad ] &&
		echo '{"text":"󰊴","tooltip":"Kept awake by controller","class":"active"}'
	;;
pads)
	# Switch-mode pads only (hid-nintendo): Xbox-mode GuliKits report no battery. Levels, not percentages.
	# Also notifies once on each drop into Low/Critical; the bar's poll is the only loop.
	state="$HOME/.local/state/pad-battery"
	mkdir -p "$state"
	text="" tip="" n=0
	for b in /sys/class/power_supply/nintendo_switch_controller_battery_*; do
		[ -e "$b" ] || continue
		n=$((n + 1))
		lvl=$(<"$b/capacity_level") st=$(<"$b/status")
		case "$lvl" in Full) g=󰁹 ;; High) g=󰂀 ;; Normal) g=󰁾 ;; Low) g=󰁻 ;; *) g=󰂃 ;; esac
		[ "$st" = Charging ] && g=󰂄
		text+="$g" tip+="Pad $n: $lvl ($st)\n"
		f="$state/${b##*/}"
		if [[ $lvl =~ ^(Low|Critical)$ ]] && [ "$(cat "$f" 2>/dev/null)" != "$lvl" ]; then
			notify-send -u "$([ "$lvl" = Critical ] && echo critical || echo normal)" "Controller battery $lvl" "Pad $n needs charging"
		fi
		echo "$lvl" >"$f"
	done
	[ "$n" -gt 0 ] && jq -cn --arg t "󰊴 $text" --arg tip "${tip%\\n}" '{text: $t, tooltip: ($tip | gsub("\\\\n"; "\n"))}'
	;;
esac
exit 0
