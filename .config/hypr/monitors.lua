-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- LG dual mode: keep the scale you pick (Omarchy's scaling menu rewrites omarchy_monitor_scale)
-- and carry it across 4K@240 <-> 1080p@480 at this ratio, never below 1. Runs on reload and when
-- the mode switch re-adds DP-1. State: "<value set> <1080p-equivalent>". GDK_SCALE reaches new apps only.
local LG_RATIO = 1.6 -- 4K scale / 1080p scale (from the 1.6 vs 1 pair used by hand)
local lg_state = os.getenv("HOME") .. "/.local/state/omarchy/lg-scale"

local function clean_scale(scale, w, h) -- same as omarchy-hyprland-monitor-scaling
  local function gcd(a, b) while b ~= 0 do a, b = b, a % b end return a end
  local g = gcd(w * 120, h * 120)
  local k = math.min(math.floor(scale * 120 + 0.5), g)
  while g % k ~= 0 do k = k + 1 end
  return k / 120
end

local function lg_dual_mode_scale()
  local m = hl.get_monitor("DP-1")
  if not m then return end
  local ratio = m.width >= 3840 and LG_RATIO or 1
  local f = io.open(lg_state)
  local written, base = (f and f:read("*a") or ""):match("([%d.]+) ([%d.]+)")
  if f then f:close() end
  if tonumber(written) ~= omarchy_monitor_scale then
    -- You just changed the scale in this mode: remember it, leave it as set
    f = io.open(lg_state, "w")
    if f then f:write(omarchy_monitor_scale, " ", omarchy_monitor_scale / ratio); f:close() end
    return
  end
  local scale = clean_scale(math.max(1, tonumber(base) * ratio), m.width, m.height)
  hl.env("GDK_SCALE", tostring(math.floor(scale + 0.5)))
  if math.abs(m.scale - scale) > 0.01 then
    hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = scale })
  end
end
hl.on("monitor.added", function()
  lg_dual_mode_scale()
  -- The switch changes DP-1's logical size and can strand floating windows off screen: re-center
  -- them once the new layout has settled
  hl.timer(function()
    for _, w in ipairs(hl.get_windows({ floating = true })) do
      -- center() aborts Hyprland on a window with no monitor/workspace (mid-switch, unmapped, hidden)
      if w.mapped and not w.hidden and w.monitor and w.workspace and w.monitor.width > 0 then
        hl.dispatch(hl.dsp.window.center({ window = "address:" .. w.address }))
      end
    end
  end, { timeout = 500, type = "oneshot" })
end)
lg_dual_mode_scale()

-- NOTE: TV (HDMI-A-1) mode/mirror lines below are overridden. Change MODE in ~/dotfiles/bin/toggle-monitor-mirror.sh
-- (SUPER+CTRL+M) instead: its rule loads after this file, then press the toggle twice to apply.
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "auto", scale = 1, mirror = "DP-1" })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
