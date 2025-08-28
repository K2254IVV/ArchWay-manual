#!/bin/bash
#ArchWay Aorus 15 series part0
mount /dev/nvme0n1p2 /mnt       # Mount root filesystem
mkdir -p /mnt/boot/efi          # Create directory for EFI partition
mount /dev/nvme0n1p1 /mnt/boot/efi  # Mount EFI partition
pacstrap /mnt base linux linux-firmware coreutils iproute2 dhcpcd iwd grub sudo nano fastfetch util-linux nvidia nvidia-utils efibootmgr os-prober intel-ucode curl wget
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOF
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
EDITOR=nano visudo # Manual editing
systemctl enable dhcpcd.service
echo ArchWayBTW > /etc/hostname
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg
microcode_ctl update
exit
EOF
echo "ArchWay Part0 for AORUS15 Series Laptop Installed! run part1.sh in arch-chroot to finish installation, goodbye! "
