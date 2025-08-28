#!/bin/bash
#ArchWay Lenovo G500 part0
mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
pacstrap /mnt base linux linux-firmware coreutils iproute2 dhcpcd iwd grub sudo nano fastfetch util-linux
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOF
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
read -p "Enter your timezone (example Europe/Moscow): " timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime # Adjust to your timezone
hwclock --systohc --utc
echo ArchWayBTW > /etc/hostname
echo "Setting the locale"
nano /etc/locale.gen
locale-gen
passwd
read -p "Enter desired username: " username
useradd -m -s /bin/bash $username
passwd $username
EDITOR=nano visudo # Manual editing
systemctl enable dhcpcd.service
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
exit
EOF
echo "ArchWay Linux Installed! reboot in 5 seconds"
umount -R /mnt
sleep 5
reboot
