#!/usr/bin/env bash
# Locks the RX 9070 XT at max clocks (high) or back to normal (auto). Resets to auto on reboot.
# Passwordless via /etc/sudoers.d/gpu-high (installed by setup.sh).
LEVEL=/sys/bus/pci/devices/0000:03:00.0/power_dpm_force_performance_level
[ "$(cat "$LEVEL")" = high ] && new=auto || new=high
if ! echo "$new" | sudo -n tee "$LEVEL" >/dev/null; then
	omarchy-notification-send -u critical "GPU clock lock failed" "Run setup.sh to install /etc/sudoers.d/gpu-high"
	exit 1
fi
[ "$new" = high ] && omarchy-notification-send -u low "GPU locked to max clocks" || omarchy-notification-send -u low "GPU clocks back to auto"
