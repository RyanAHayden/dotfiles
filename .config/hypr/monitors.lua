-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- NOTE: TV (HDMI-A-1) mode/mirror lines below are overridden. Change MODE in ~/dotfiles/bin/toggle-monitor-mirror.sh
-- (SUPER+CTRL+M) instead: its rule loads after this file, then press the toggle twice to apply.
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "auto", scale = 1, mirror = "DP-1" })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Always-present tiny headless output, far off-screen on its own workspace.
-- ponytail: workaround for Hyprland 0.56.2 SEGV in CDefaultFloatingAlgorithm::newTarget when a window
-- maps while the only real monitor (DP-1, drops off DP in sleep) is gone. Drop once upstream fixes it.
hl.monitor({ output = "HEADLESS-KEEP", mode = "640x480@10", position = "-10000x-10000", scale = 1 })
hl.workspace_rule({ workspace = "name:keep", monitor = "HEADLESS-KEEP", default = true })
-- ponytail: part of the same temporary workaround; remove with HEADLESS-KEEP.
-- Workspaces stranded on HEADLESS-KEEP while DP-1 was gone go back to DP-1 when it returns.
hl.on("monitor.added", function()
  hl.exec_cmd([[sleep 1; hyprctl workspaces -j | jq -r '.[] | select(.monitor == "HEADLESS-KEEP" and .name != "keep") | .name' | while read -r ws; do hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"DP-1\" })"; done; hyprctl --batch 'dispatch hl.dsp.focus({ monitor = "HEADLESS-KEEP" }) ; dispatch hl.dsp.focus({ workspace = "name:keep" }) ; dispatch hl.dsp.focus({ monitor = "DP-1" })']])
end)
