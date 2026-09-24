-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- System-wide CRT scanline/vignette effect (applies to everything: PCSX2, browser, terminal, etc.)
-- Source: https://github.com/zer0-sh/retro-shader-hyperland (GPL-3.0)
-- Toggled via ~/.config/hypr/scripts/toggle-crt.sh, which flips this state file and reloads.
-- (Reload, not `hyprctl eval`/`keyword`, because runtime screen_shader changes don't force a
-- redraw in this Hyprland version and leave a stale frame until an unrelated redraw happens.)
local crt_state_file = "/home/ryha/.local/state/crt-shader-enabled"
local crt_state = io.open(crt_state_file, "r")
if crt_state then
  crt_state:close()
  hl.config({
    decoration = {
      screen_shader = "/home/ryha/.config/hypr/shaders/crt_hypr.frag",
    },
  })
end

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
