# My Omarchy Dotfiles

Use at your own risk

## Install extra packages

`omarchy pkg add bluetui wiremix`

## Enable autostart for wayvnc

`systemctl --user enable --now wayvnc`  
`loginctl enable-linger $USER`

install theme:
`https://github.com/RyanAHayden/ryha-omarchy-theme`

## keyd (Left Ctrl held + hjkl = arrows)

`sudo stow -t / etc`
`sudo systemctl enable --now keyd`
