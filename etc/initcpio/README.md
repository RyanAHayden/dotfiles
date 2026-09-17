# No LUKS passphrase at boot: TPM2 auto-unlock + Secure Boot

Root (`/dev/nvme0n1p2`, mapped as `root`) is LUKS2-encrypted. Goal: unlock it
automatically via the TPM2 chip so there's no passphrase prompt at boot, with
the original passphrase kept as a fallback. This machine boots a Limine UKI
(`/EFI/Linux/omarchy_linux.efi`) built by `limine-mkinitcpio`, using the
classic (non-systemd) mkinitcpio `encrypt` hook — not `sd-encrypt`.

Two things had to be true before TPM2 binding was worth doing, and one extra
hook was needed on top of the normal `systemd-cryptenroll` step. All three
are captured below.

## Steps (redo after a fresh Omarchy install)

```bash
# 1. Secure Boot with your own keys (skip the PCR-7 binding below if you
#    don't want to bother with this — see "Why Secure Boot" below).
sudo pacman -S sbctl
sudo sbctl status   # check "Setup Mode" — if disabled, reset Secure Boot to
                     # Setup Mode in the BIOS first, reboot, re-check
sudo sbctl create-keys
sudo sbctl enroll-keys -m        # -m: also trust Microsoft's certs (dual-boot Windows)
sudo sbctl sign -s /boot/EFI/limine/limine_x64.efi
sudo sbctl sign -s /boot/EFI/Linux/omarchy_linux.efi
sudo sbctl verify   # the two files above should show signed; Microsoft's own
                     # bootmgfw.efi etc. show "not signed" — that's fine, they
                     # carry their own Microsoft signature already

# Now go into BIOS: set Secure Boot Mode to "Custom" (NOT "Windows UEFI
# Mode"/"Standard" — see gotcha below), enable the Secure Boot toggle, save,
# reboot. Confirm with:
bootctl status   # should show "Secure Boot: enabled (user)"

# 2. Bind a TPM2 key slot to the LUKS volume (passphrase slot is kept)
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2

# 3. Bundle the TPM2 cryptsetup plugin into the initramfs (see mkinitcpio
#    hooks in this directory) and make the encrypt hook actually try it
#    (see gotcha below), then rebuild:
sudo install -Dm755 ~/dotfiles/etc/initcpio/install/tpm2-cryptsetup /etc/initcpio/install/tpm2-cryptsetup
sudo install -Dm755 ~/dotfiles/etc/initcpio/hooks/tpm2-cryptsetup /etc/initcpio/hooks/tpm2-cryptsetup

# Add tpm2-cryptsetup right before encrypt in the HOOKS line that actually
# wins on this system: /etc/mkinitcpio.conf.d/omarchy_hooks.conf (NOT the
# HOOKS line in /etc/mkinitcpio.conf itself — that one is overridden, see
# gotcha below). Compare against the copy of that file kept in this repo,
# then either edit /etc/mkinitcpio.conf.d/omarchy_hooks.conf by hand or:
sudo sed -i 's/ encrypt / tpm2-cryptsetup encrypt /' /etc/mkinitcpio.conf.d/omarchy_hooks.conf

sudo mkinitcpio -P
```

Reboot. It should go straight to the login screen with no LUKS prompt at
all.

## Gotchas that ate the most time

**"Windows UEFI Mode" / "Standard" wipes your custom keys.** On this board,
Secure Boot Mode has two (or three, once custom keys exist) options. Setting
it to "Windows UEFI Mode"/"Standard" reloads the board's factory/Microsoft
key database and drops the custom PK/KEK/db that `sbctl enroll-keys` wrote —
next boot fails with "Secure Boot Violation" on Limine (which is signed with
the custom key, not Microsoft's). Fix: once keys are enrolled, leave the mode
on **Custom** and only touch the Secure Boot on/off toggle.

**Plymouth never even tries the TPM token.** The stock `/usr/lib/initcpio/
hooks/encrypt` (classic, non-systemd initramfs) has two code paths for asking
the passphrase. When Plymouth is running (it is, for the splash screen), it
always takes the branch that calls `plymouth ask-for-password --command=
"cryptsetup open --key-file=- ..."` — feeding whatever's typed straight in as
the key, with **no attempt at LUKS2 token auto-discovery first**. Just
bundling the TPM2 plugin + `tpm2-tss` libs into the initramfs (the
`tpm2-cryptsetup` install hook here) is necessary but not sufficient — nothing
ever calls it.

The fix exploits an escape hatch already in that hook: it checks
`[ -b "/dev/mapper/${cryptname}" ]` right at the top and skips everything
(no prompt) if the device is already unlocked. The `tpm2-cryptsetup` runtime
hook here runs *before* `encrypt` in HOOKS and does exactly one thing:
`cryptsetup open --type luks --token-only` — tries the TPM2 token only, fails
silently (no passphrase prompt) if it doesn't work. If it succeeds, `encrypt`
sees the device already exists and skips its own passphrase logic — Plymouth
never gets asked to show a prompt. If the TPM attempt fails (PCR mismatch,
TPM busy, etc.), `encrypt` runs exactly as before and you type the
passphrase like normal.

**The HOOKS line that matters isn't in `/etc/mkinitcpio.conf`.**
`/etc/mkinitcpio.conf.d/omarchy_hooks.conf` does a full `HOOKS=(...)`
reassignment and, as a drop-in, loads *after* the base config — silently
winning. Editing `/etc/mkinitcpio.conf`'s `HOOKS=` line directly has no
effect on this system; the drop-in is what `mkinitcpio -P` actually uses
(confirm with `grep HOOKS= /etc/mkinitcpio.conf.d/omarchy_hooks.conf` after
a rebuild — the build log's `-> Running build hook: [...]` list is the
ground truth either way).

## Verifying it's still wired up correctly

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2   # slot 0 = passphrase, slot 1 = systemd-tpm2 token
lsinitcpio /boot/EFI/Linux/omarchy_linux.efi | grep -E 'tss2|tpm2-cryptsetup|hooks/encrypt'
bootctl status                            # Secure Boot: enabled (user)
sudo sbctl verify                         # limine_x64.efi and omarchy_linux.efi signed
```

## If it breaks

The passphrase (LUKS slot 0) still works — type it like before, nothing was
removed. If a kernel/firmware update changes PCR 0 (or you touch BIOS
settings that change PCR 7), the TPM unlock will just silently fail and fall
back to the passphrase prompt; re-run the `systemd-cryptenroll` command from
step 2 above to re-bind. Omarchy's `limine-entry-tool` re-signs the UKI and
Limine binary automatically on every kernel update once `sbctl` is enrolled
(see `sb_sign()` in `/usr/lib/limine/limine-common-functions`), so Secure
Boot signing doesn't need redoing after normal updates.

To fully back out: `sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2`,
remove `tpm2-cryptsetup` from the HOOKS line in
`/etc/mkinitcpio.conf.d/omarchy_hooks.conf`, and `sudo mkinitcpio -P`.
