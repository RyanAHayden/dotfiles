#!/bin/bash
# Advanced/optional: makes sure sddm actually asks for a password at
# login (no autologin). Run this AFTER setting up TPM2 auto-unlock /
# secure boot (see etc/initcpio/README.md) - that setup removes the
# LUKS passphrase prompt, so without this step the machine would boot
# straight to the desktop with no password prompt anywhere at all.
set -euo pipefail

if [ -f /etc/sddm.conf.d/autologin.conf ]; then
  echo "Removing /etc/sddm.conf.d/autologin.conf"
  sudo rm /etc/sddm.conf.d/autologin.conf
else
  echo "No autologin.conf present - already good"
fi

echo "Done - reboot and confirm sddm asks for your password."
