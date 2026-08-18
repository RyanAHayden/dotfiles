#!/bin/bash
set -euo pipefail

selection=$(omarchy-menu-select "Pointer speed" \
  "1: Slow (-0.6)" \
  "2: Slower (-0.2)" \
  "3: Faster (0.2)" \
  "4: Fast (0.6)" \
  -- --width 400)

case "$selection" in
  "1: Slow (-0.6)")    hyprctl eval 'hl.config({input={sensitivity=-0.6}})' ;;
  "2: Slower (-0.2)")  hyprctl eval 'hl.config({input={sensitivity=-0.2}})' ;;
  "3: Faster (0.2)")   hyprctl eval 'hl.config({input={sensitivity=0.2}})' ;;
  "4: Fast (0.6)")     hyprctl eval 'hl.config({input={sensitivity=0.6}})' ;;
esac
