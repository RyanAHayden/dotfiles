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
-- ponytail: part of the same temporary workaround; remove with HEADLESS-KEEP.
-- HEADLESS-KEEP ignores its position rule (stuck at 0x0 since a wayvnc resize), so keep DP-1 out of its reach:
-- a gap between them means the cursor can't cross onto it (the focus bounce below would yank it back).
hl.monitor({ output = "DP-1", mode = "preferred", position = "5000x0", scale = omarchy_monitor_scale })
hl.workspace_rule({ workspace = "name:keep", monitor = "HEADLESS-KEEP", default = true })
-- ponytail: part of the same temporary workaround; remove with HEADLESS-KEEP.
-- Workspaces stranded on HEADLESS-KEEP while DP-1 was gone go back to DP-1 when it returns.
hl.on("monitor.added", function()
  hl.exec_cmd([[sleep 1; hyprctl workspaces -j | jq -r '.[] | select(.monitor == "HEADLESS-KEEP" and .name != "keep") | .name' | while read -r ws; do hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"DP-1\" })"; done; hyprctl --batch 'dispatch hl.dsp.focus({ monitor = "HEADLESS-KEEP" }) ; dispatch hl.dsp.focus({ workspace = "name:keep" }) ; dispatch hl.dsp.focus({ monitor = "DP-1" })']])
end)
-- ponytail: part of the same temporary workaround; remove with HEADLESS-KEEP.
-- Bounce focus off HEADLESS-KEEP to a real monitor so new windows never land there. Skipped while it shows a
-- stray workspace, so the restore-`keep` batches above and in toggle-tv-power.sh can still focus it.
hl.on("monitor.focused", function(m)
  if not m or m.name ~= "HEADLESS-KEEP" or not m.active_workspace or m.active_workspace.name ~= "keep" then return end
  for _, o in ipairs(hl.get_monitors()) do
    -- Async: dispatching focus inside the focus event gets overridden by the focus still in progress.
    if o.name ~= "HEADLESS-KEEP" then return hl.exec_cmd("hyprctl dispatch 'hl.dsp.focus({ monitor = \"" .. o.name .. "\" })'") end
  end
end)
