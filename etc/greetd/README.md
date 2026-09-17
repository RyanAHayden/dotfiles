# Password at startup: sddm -> greetd

Omarchy ships SDDM with autologin baked in ([known issue, no clean disable](https://github.com/omacom/omarchy/discussions/3540)) — removing `/etc/sddm.conf.d/autologin.conf` does not stop it. The fix is replacing SDDM with `greetd` + `tuigreet`, which prompts for a real password every boot.

## Steps (redo after a fresh Omarchy install)

```bash
# 1. Install greetd + a greeter
sudo pacman -S greetd greetd-tuigreet

# 2. Symlink config.toml in this repo over the installed default
sudo ln -sfn ~/dotfiles/etc/greetd/config.toml /etc/greetd/config.toml

# 3. Swap the enabled display manager (does not kill your current session,
#    takes effect next boot)
sudo systemctl disable sddm.service
sudo systemctl enable greetd.service

# 4. Reboot and confirm tuigreet asks for a password
```

`config.toml` launches the session the same way sddm did: `uwsm start -g -1 -e -D Hyprland hyprland.desktop`. `--remember --remember-session` just prefill username/session like sddm's `RememberLastUser`/`RememberLastSession` did — no autologin.

sddm itself is left installed (just disabled) in case of rollback:

```bash
sudo systemctl disable greetd.service
sudo systemctl enable sddm.service
```
