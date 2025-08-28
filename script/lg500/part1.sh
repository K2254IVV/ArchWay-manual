#!/bin/bash
#ArchWay Lenovo G500 part1
echo "=================================================================="
echo "                 ArchWay Part1.sh "
echo "=================================================================="

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
sh -c "$(curl -fsSL "https://raw.githubusercontent.com/K2254IVV/ArchWay-manual/refs/heads/main/script/include/0.sh")"
exit

echo "ArchWay Linux Installed! please Exit from arch-chroot and finish installation:" 
echo "umount -R /mnt "
echo "sleep 5" 
echo "reboot"
