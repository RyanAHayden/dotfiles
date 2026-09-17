# My Omarchy Dotfiles

Use at your own risk
`./setup.sh` - stows using --adopt so you can see git changes before discarding what you want to change. It also installs theme and sets boot logo and limine

## Install extra packages

`omarchy pkg add bluetui wiremix`

## Enable autostart for wayvnc

`systemctl --user enable --now wayvnc`  
`loginctl enable-linger $USER`

Theme:
`https://github.com/RyanAHayden/ryha-omarchy-theme`

## sddm theme, boot logo, limine theme

`./setup.sh` (redeploys all three`omarchy refresh sddm`/`omarchy refresh limine`)

Discord Theme (Vencord):
`https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-auto.theme.css`
