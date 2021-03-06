#!/bin/bash

die() {
	if [[ ! -z "$1" ]]; then echo "Error: $1" >&2; fi
	echo "Exiting..." >&2; exit 1
}

read -r BD_PW
PART="$1"
CRYPTROOT="$2"

echo -n "$BD_PW" | cryptsetup open "$PART" "$CRYPTROOT" - ||
  die "$LINENO: couldn't cryptsetup open $PART"

mount "/dev/mapper/$CRYPTROOT" /mnt ||
  die "$LINENO: couldn't mount $CRYPTROOT to /mnt"

pacman-key --init
pacman-key --populate archlinux

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
rankmirrors -n 3 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

pacman --noconfirm -Syuu

PKGS="base base-devel arch-install-scripts sudo"
pacstrap /mnt $PKGS

umount "/dev/mapper/$CRYPTROOT" || die "couldn't umount $CRYPTROOT"

exit 0
