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
