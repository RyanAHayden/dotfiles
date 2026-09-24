# sddm themes: copy, don't symlink

Everything else in this repo's `etc/` gets deployed to the live system as a
symlink. **These do not** — SDDM starts before `/home` is reliably mounted
on this machine (separate btrfs subvolume, no explicit ordering dependency
in `sddm.service`), so a symlink from `/usr/share/sddm/themes/...` or
`/etc/sddm.conf.d/...` back into `~/dotfiles` resolves fine when you check
it manually (you're already logged in, `/home` is up) but fails at actual
boot with `No such file or directory` - happened with `omarchy-red`
2026-09-16.

Deploy with a real copy instead:

```bash
sudo cp -r ~/dotfiles/etc/sddm-themes/omarchy-red /usr/share/sddm/themes/omarchy-red
sudo cp ~/dotfiles/etc/sddm.conf.d/10-theme.conf /etc/sddm.conf.d/10-theme.conf
```

Re-run both after editing the theme in this repo - there's no live link to
keep them in sync automatically.

`../../.stowrc` excludes `sddm-themes/` and `sddm.conf.d/` from `stow`, so
running stow over `etc/` won't undo this and resymlink them.
