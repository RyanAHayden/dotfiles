-- Extra autostart processes.
-- o.launch_on_start("my-service")
o.launch_on_start("~/bin/gamepad-stay-awake")


-- Windows-style Alt+Tab preview overlay (from github.com/ilsmith0421/dotfiles).
o.launch_on_start("quickshell -n -p $HOME/.config/quickshell/recent-windows")
hl.layer_rule({ match = { namespace = "recent-window-switcher" }, no_anim = true, animation = "none" })
