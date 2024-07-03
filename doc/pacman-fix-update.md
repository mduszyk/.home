# mount encrypted disk
- lsblk
- cryptsetup -v luksOpen /dev/nvme0n1p2 root
- mount /dev/mapper/root /mnt
- cd /mnt

# download static pacman
- wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
- wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static.sig
- gpg --keyserver-options auto-key-retrieve --verify pacman-static.sig

# chroot
- mount /dev/nvme0n1p1 /mnt/boot/efi
- mount -t proc /proc /mnt/proc/
- mount -t sysfs /sys /mnt/sys/
- mount --rbind /dev /mnt/dev/
- mount --rbind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars/
- chroot /mnt /bin/bash

# fix broken update
- rm /var/lib/pacman/db.lck
- pacman-mirrors -f
- pacman-static -Syyu
- pacman-static -Qqe | pacman-static --overwrite '*' -S -
- update-grub
- exit

