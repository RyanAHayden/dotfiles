#!/bin/bash
# Step the focused window's opacity by $1 (e.g. -0.05 or +0.05), focused and unfocused alike, kept in 0.2..1.
a=$(hyprctl activewindow -j | jq -r .address)
v=$(awk -v c="$(hyprctl getprop "address:$a" opacity)" -v d="$1" 'BEGIN { v = c + d; if (v < 0.2) v = 0.2; if (v > 1) v = 1; print v }')
for p in opacity opacity_inactive; do
  hyprctl dispatch "hl.dsp.window.set_prop({ window = \"address:$a\", prop = \"$p\", value = \"$v\" })" >/dev/null
done
