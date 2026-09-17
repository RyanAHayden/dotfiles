# My Omarchy Dotfiles

Use at your own risk

## Install extra packages

`omarchy pkg add bluetui wiremix`

## Enable autostart for wayvnc

`systemctl --user enable --now wayvnc`  
`loginctl enable-linger $USER`

Install theme:
`https://github.com/RyanAHayden/ryha-omarchy-theme`
Enable boot logo:
`omarchy plymouth set by theme ryha-omarchy`
