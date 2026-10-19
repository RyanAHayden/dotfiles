#!/bin/bash
# Toggle a title tab above every tiled window by wrapping each in its own group
# (new windows too, via a window rule in Omarchy's sourced toggles dir).
flag=~/.local/state/omarchy/toggles/hypr/window-titles.lua
if [[ -f $flag ]]; then
  rm "$flag"
  want=1 # ungroup solo groups
else
  mkdir -p "${flag%/*}"
  echo 'hl.window_rule({ match = { class = ".*", float = false }, group = "set" })' >"$flag"
  want=0 # group ungrouped windows
fi
# ponytail: only touches solo groups, so real multi-window groups are left alone
hyprctl clients -j | jq -r --argjson n "$want" '.[] | select(.mapped and (.floating | not) and (.grouped | length) == $n) | .address' |
  while read -r a; do hyprctl dispatch "hl.dsp.group.toggle({ window = \"address:$a\" })" >/dev/null; done
hyprctl reload >/dev/null
