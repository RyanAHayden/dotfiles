# My Omarchy Dotfiles

Use at your own risk

## Install extra packages

`omarchy pkg add bluetui wiremix`

## Enable autostart for wayvnc

`systemctl --user enable --now wayvnc`  
`loginctl enable-linger $USER`

Install theme:
`https://github.com/RyanAHayden/ryha-omarchy-theme`

## sddm theme, boot logo, limine theme

`./setup.sh` (redeploys all three - safe to re-run, e.g. after
`omarchy refresh sddm`/`omarchy refresh limine`)

Discord Theme (Vencord):
`https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-auto.theme.css`
