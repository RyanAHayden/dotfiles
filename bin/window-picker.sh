#!/bin/bash
# List open windows by title in the Omarchy menu; focus the one picked.
mapfile -t opts < <(hyprctl clients -j | jq -r '.[] | select(.mapped and .title != "") | "󰖯\t\(.title)\t\(.class) · ws \(.workspace.name) · \(.address)"')
pick=$(omarchy-menu-select Windows "${opts[@]}") || exit 0
addr=${pick##* · }
hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
