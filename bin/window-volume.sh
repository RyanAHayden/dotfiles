#!/bin/bash
# Change volume of the window under the cursor: $1 = +5% / -5% / mute.
# Matches audio streams whose process (or its client's) is the window's pid or a descendant of it.
read -r x y < <(hyprctl cursorpos | tr -d ,)
wpid=$(hyprctl clients -j | jq --argjson x "$x" --argjson y "$y" -r '
  [.[] | select(.mapped and .workspace.id >= 0 and (.hidden | not)
    and $x >= .at[0] and $x < .at[0] + .size[0] and $y >= .at[1] and $y < .at[1] + .size[1])]
  | sort_by(.focusHistoryID) | .[0].pid // empty')
[ -n "$wpid" ] || exit

clients=$(pactl -f json list clients)
pactl -f json list sink-inputs | jq -r --argjson c "$clients" '.[] | .client as $cl |
  "\(.index) \(.properties."application.process.id" // ($c[] | select(.index == ($cl | tonumber)) | .properties."application.process.id") // 0)"' |
while read -r idx pid; do
  # ponytail: walk up from the stream pid; misses apps whose audio runs in a sibling process (e.g. sandboxed browsers' audio service usually still descends)
  while [ "$pid" -gt 1 ] && [ "$pid" != "$wpid" ]; do pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ') || break; [ -n "$pid" ] || break; done
  [ "$pid" = "$wpid" ] || continue
  if [ "$1" = mute ]; then pactl set-sink-input-mute "$idx" toggle
  else pactl set-sink-input-volume "$idx" "$1"; fi
done
