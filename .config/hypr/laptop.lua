-- Laptop mode: true on a laptop (lid switch or laptop chassis, per Omarchy's omarchy-hw-laptop), false on the desktop.
-- Desktop-only config (LG dual mode, monitor pinning, ...) checks it: `if not require("hypr.laptop") then ... end`.
-- setup.sh and bin/ scripts use the same check: `omarchy-hw-laptop`.
-- Not os.execute(): Hyprland reaps its own children, so it never sees the exit status and returns nil (always false).
return o.shell_succeeds("omarchy-hw-laptop")
