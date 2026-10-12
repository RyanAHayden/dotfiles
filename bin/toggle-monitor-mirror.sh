#!/bin/bash
# TV mode; this rule loads after monitors.lua, so it overrides the mode set there.
MODE="3840x2160@120"
FLAG="$HOME/.local/state/omarchy/toggles/hypr/monitor-mirror.lua"

# Hyprland doesn't un-mirror just because the rule disappears; it needs an
# explicit mirror = "none", so this always writes a rule rather than deleting.
if grep -q 'mirror = "DP-1"' "$FLAG" 2>/dev/null; then
  # Un-mirroring in place leaves the TV without a real output, so the shell never draws
  # on it (black screen). Disabling first makes the reload re-add it as a new monitor.
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })' >/dev/null
  sleep 1
  printf 'hl.monitor({ output = "HDMI-A-1", mode = "%s", position = "auto", scale = 1, mirror = "none" })\n' "$MODE" >"$FLAG"
else
  printf 'hl.monitor({ output = "HDMI-A-1", mode = "%s", position = "auto", scale = 1, mirror = "DP-1" })\n' "$MODE" >"$FLAG"
fi

hyprctl reload
