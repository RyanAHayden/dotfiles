-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

hl.env("GDK_SCALE", "1")

-- Straight 1x setup (fallback for any monitor not matched below)
hl.monitor({ output = "", mode = "2560x1440p@300", position = "auto", scale = 1 })

-- TV
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto", scale = 3 })
