-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Let XWayland apps (e.g. Ghidra/Java Swing) report the real fractional
-- monitor scale instead of being force-upscaled from 1x. Trade-off: some
-- other X11 apps may render blurrier. Revert by deleting this block if so.
-- hl.config({
-- 	xwayland = {
-- 		force_zero_scaling = false,
-- 	},
-- })

-- Override Steam's own minimum window size so it can be resized smaller
-- than its built-in floor.
o.window({ class = "steam" }, { min_size = { 100, 100 } })

-- Let CS2 tear (allow_tearing master toggle is in looknfeel.lua). Only
-- takes effect when the window is fullscreen and solitary.
o.window({ class = "cs2" }, { immediate = true })

-- bluetui/wiremix terminal popups (SUPER+CTRL+B / SUPER+CTRL+A) float by default.
o.window("bluetui", { float = true, center = true })
o.window("wiremix", { float = true, center = true })

-- DaVinci Resolve's XWayland popups fight the main window for focus and
-- flash borders/opacity. Pin them focused and flatten their look.
o.window({ class = "resolve", float = true }, { tag = "+drpopup" })
o.window({ tag = "drpopup" }, {
	stay_focused = false,
	tag = "-default-opacity",
	no_shadow = true,
	border_size = 0,
	rounding = 0,
	opacity = "1 1",
})

-- open-tennis test windows (the remaster's --shot runs are titled "Hot Shots Tennis (shot)";
-- a normal launch is plain "Hot Shots Tennis" and opens normally; PCSX2 is class pcsx2-qt) open on workspace 1
-- without taking focus, and drop under every other window there as soon as they map.
-- ponytail: Hyprland draws floating windows above tiled ones, so a floating test
-- window still covers a *tiled* focused window; float yours to keep it on top.
o.window({ class = "^pcsx2-qt$" }, { workspace = "1 silent", no_initial_focus = true })
o.window({ title = "^Hot Shots Tennis \\(shot\\)$" }, { workspace = "1 silent", no_initial_focus = true })

-- Scratchpad apps (toggled by ~/bin/scratch-app from bindings.lua)
o.window({ class = "^discord$" }, { workspace = "special:scratchpad silent" })
o.window({ class = "^org\\.keepassxc\\.KeePassXC$" }, { workspace = "special:scratchpad silent" })

hl.on("window.open", function(w)
	if w.class == "pcsx2-qt" or w.title == "Hot Shots Tennis (shot)" then
		hl.dispatch(hl.dsp.window.alter_zorder({ mode = "bottom", window = "address:" .. w.address }))
	end
end)
