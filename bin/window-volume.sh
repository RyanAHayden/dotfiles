#!/bin/bash
# Change volume of the window under the cursor: $1 = +5% / -5% / mute. Shows the Omarchy OSD.
# Matches audio streams whose process (or its client's) is the window's pid or a descendant of it.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/window-volume.lock"; flock 9 # serialize fast scrolls so steps apply in order
read -r x y < <(hyprctl cursorpos | tr -d ,)
wpid=$(jq -n --argjson x "$x" --argjson y "$y" --argjson m "$(hyprctl monitors -j)" --argjson c "$(hyprctl clients -j)" -r '
  ([$m[] | .activeWorkspace.id, .specialWorkspace.id]) as $ws
  | [$c[] | select(.mapped and (.hidden | not) and (.workspace.id as $w | $ws | index($w))
    and $x >= .at[0] and $x < .at[0] + .size[0] and $y >= .at[1] and $y < .at[1] + .size[1])]
  | sort_by(.focusHistoryID) | .[0].pid // empty')
[ -n "$wpid" ] || exit

clients=$(pactl -f json list clients)
ids=$(pactl -f json list sink-inputs | jq -r --argjson c "$clients" '.[] | .client as $cl |
  "\(.index) \(.properties."application.process.id" // ($c[] | select(.index == ($cl | tonumber)) | .properties."application.process.id") // 0)"' |
while read -r idx pid; do
  # ponytail: walk up from the stream pid; misses apps whose audio runs in a non-descendant process
  while [ "$pid" -gt 1 ] && [ "$pid" != "$wpid" ]; do pid=$(ps -o ppid= -p "$pid" | tr -d ' '); [ -n "$pid" ] || break; done
  [ "$pid" = "$wpid" ] && echo "$idx"
done)
[ -n "$ids" ] || { omarchy-osd -i volume-muted -m "No audio"; exit; }

for idx in $ids; do
  if [ "$1" = mute ]; then pactl set-sink-input-mute "$idx" toggle
  else pactl set-sink-input-volume "$idx" "$1"; fi
done

read -r vol mute < <(pactl -f json list sink-inputs | jq -r --argjson i "${ids%%$'\n'*}" \
  '.[] | select(.index == $i) | "\(.volume | to_entries[0].value.value_percent | rtrimstr("%")) \(.mute)"')
[ "$mute" = true ] || [ "$vol" = 0 ] && icon=volume-muted || icon=volume-high
omarchy-osd -i "$icon" -p "$vol"
