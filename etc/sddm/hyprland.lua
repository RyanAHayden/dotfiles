-- SDDM greeter: stock Omarchy config + screen off when idle (burn-in protection).
dofile("/usr/share/sddm/hyprland.lua")

hl.config({
  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

hl.on("hyprland.start", function()
  hl.exec_cmd("hypridle -c /etc/sddm/hypridle.conf")
end)
