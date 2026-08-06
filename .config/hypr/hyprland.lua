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
