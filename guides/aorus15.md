
# Minimal Arch Linux Installation Guide for Aorus Series 15 Laptop (NVIDIA + Intel Core i7)

This guide will walk you through installing a minimal Arch Linux distribution on an Aorus series 15 laptop featuring NVIDIA graphics card and Intel Core i7 processor in x86_64 architecture. The laptop supports UEFI boot mode.

## Prerequisites

Before proceeding, ensure that:
* Your disk has two partitions set up: `/dev/nvme0n1p1` (EFI Boot, FAT32) and `/dev/nvme0n1p2` (Root filesystem, ext4).
* Secure Boot is disabled in BIOS settings if necessary.
* Internet connection via Ethernet or Wi-Fi is established.

## Step-by-step Installation Process

### 1. Boot into Arch Linux Live Environment
Use an Arch Linux ISO live USB stick to start the installation process.

### 2. Connect to the Internet
Check internet connectivity by pinging Google DNS server:
```bash
ping -c 3 www.google.com
```
If you're not connected, configure your network manually using either wired (`dhcpcd`) or wireless (`iw`). For example:
```bash
ip link show   # Check available interfaces
dhcpcd eth0   # Enable DHCP for Ethernet interface
```

### 3. Prepare Disk Partitions
Mount the prepared partitions:
```bash
mount /dev/nvme0n1p2 /mnt       # Mount root filesystem
mkdir -p /mnt/boot/efi          # Create directory for EFI partition
mount /dev/nvme0n1p1 /mnt/boot/efi  # Mount EFI partition
```

### 4. Install Base Packages
We'll install essential packages including the Linux kernel, firmware, and other tools needed for basic operation:
```bash
pacstrap /mnt base linux linux-firmware coreutils iproute2 dhcpcd iwd grub sudo nano fastfetch util-linux nvidia nvidia-utils efibootmgr os-prober intel-ucode curl wget
```

### 5. Generate FSTAB Table
Generate the `fstab` table which lists all mounted filesystems:
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### 6. Chroot into New Environment
Switch to the newly installed environment:
```bash
arch-chroot /mnt
```

### 7. Configure Locale & Time Zone
Adjust these according to your region:
```bash
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime     # Change time zone accordingly
hwclock --systohc --utc
nano /etc/locale.gen
locale-gen
```

### 8. Set Hostname
Provide a unique hostname for your system:
```bash
echo myhostname > /etc/hostname
```

### 9. Create a Normal User Account
Add a regular user account along with setting its password:
```bash
useradd -m -s /bin/bash username
passwd username
```

### 10. Allow Sudo Access
Grant administrative privileges to the new user by editing the `sudoers` file:
```bash
EDITOR=nano visudo      # Uncomment %wheel group line
```

### 11. Install GRUB Bootloader
Configure and install GRUB for UEFI booting:
```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg
```

### 12. Update Microcode
Update CPU microcode for better performance/stability:
```bash
microcode_ctl update
```

### 13. Exit Chroot and Reboot
Unmount all filesystems and restart the computer:
```bash
exit
umount -R /mnt
reboot
```

After rebooting, log in with your new credentials and verify successful installation of the operating system.

---

Congratulations! You've completed a bare-bones Arch Linux installation tailored specifically for your Aorus Series 15 notebook.
