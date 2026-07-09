#!/bin/bash
STATE_FILE="/tmp/hypr-quadrant-active"
WS=$(hyprctl activeworkspace -j | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

if [[ -f "$STATE_FILE" ]]; then
    rm "$STATE_FILE"

    if omarchy-hyprland-toggle-enabled window-no-gaps; then
        omarchy-hyprland-toggle window-no-gaps
    fi

    if ! pgrep -x waybar >/dev/null; then
        omarchy toggle waybar
    fi

    hyprctl clients -j | python3 -c "
import sys, json, subprocess
for c in json.load(sys.stdin):
    if c['workspace']['id'] == $WS:
        subprocess.run(['hyprctl', 'dispatch', 'setprop', 'address:' + c['address'], 'opaque', '0'])
"
else
    touch "$STATE_FILE"

    if pgrep -x waybar >/dev/null; then
        omarchy toggle waybar
    fi

    if omarchy-hyprland-toggle-disabled window-no-gaps; then
        omarchy-hyprland-toggle window-no-gaps
    fi

    hyprctl clients -j | python3 -c "
import sys, json, subprocess
for c in json.load(sys.stdin):
    if c['workspace']['id'] == $WS:
        subprocess.run(['hyprctl', 'dispatch', 'setprop', 'address:' + c['address'], 'opaque', '1'])
"
fi
