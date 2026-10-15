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
  # Extended: the TV gets workspace 2 only; everything else stays on DP-1.
  {
    printf 'hl.monitor({ output = "HDMI-A-1", mode = "%s", position = "auto", scale = 1, mirror = "none" })\n' "$MODE"
    echo 'hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default = true })'
    for ws in 1 3 4 5 6 7 8 9 10; do echo "hl.workspace_rule({ workspace = \"$ws\", monitor = \"DP-1\" })"; done
  } >"$FLAG"
  EXTENDED=1
else
  # A mirroring monitor keeps the workspaces it owned while extended, stranding them; hand them to DP-1 first.
  hyprctl workspaces -j | jq -r '.[] | select(.monitor == "HDMI-A-1" and (.name | startswith("special:") | not)) | .name' |
    while read -r ws; do hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"DP-1\" })" >/dev/null; done
  printf 'hl.monitor({ output = "HDMI-A-1", mode = "%s", position = "auto", scale = 1, mirror = "DP-1" })\n' "$MODE" >"$FLAG"
fi

hyprctl reload >/dev/null
# Rules only place new workspaces; an existing workspace 2 has to be moved explicitly.
if [ -n "$EXTENDED" ]; then
  sleep 1
  hyprctl dispatch 'hl.dsp.workspace.move({ workspace = "2", monitor = "HDMI-A-1" })' >/dev/null
  hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-1" })' >/dev/null
fi
