-- Extra autostart processes.
-- o.launch_on_start("my-service")
o.launch_on_start("~/bin/gamepad-stay-awake")

-- Keep a headless output alive so Hyprland never has zero monitors (see monitors.lua).
hl.on("hyprland.start", function()
  hl.exec_cmd("hyprctl output create headless HEADLESS-KEEP")
end)
