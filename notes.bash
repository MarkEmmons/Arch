gdisk
n
+300M
ef00

n
+1G
8200

n

8300

cryptsetup luksFormat /dev/vda3
cryptsetup luksOpen /dev/vda3 cryptroot

# Use mapper because we want to format the opened partition
mkfs.fat -F32 /dev/vda1
mkswap /dev/vda2
swapon /dev/vda2
mkfs.btrfs /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
cd
umount /mnt

# -o means options
# discard=async is good for SSD
mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
mkdir /mnt/home
mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

pacstrap /mnt base linux linux-firmware git vim btrfs-progs

genfstab -U /mnt/etc/fstab
arch-chroot /mnt

# :)

# https://gitlab.com/eflinux/arch-basic
grub-btrfs

#grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

add encrypt hook to mkinitcpio
mkinitcpio -p linux

blkid

vim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT+="cryptdevice=UUID=<>:cryptroot root=/dev/mapper/cryptroot"
grub-mkconfig -o /boot/grub/grub.cfg

reboot

# It is more reliable to identify the correct partition by giving it a genuine UUID or LABEL.
# By default that does not work because dm-crypt and mkswap would simply overwrite any content on that partition which would remove the UUID and LABEL too;
# however, it is possible to specify a swap offset.
# This allows you to create a very small, empty, bogus filesystem with no other purpose than providing a persistent UUID or LABEL for the swap encryption.

swapoff /dev/vda2
mkfs.ext2 -L cryptswap /dev/vda2 1M #y

vim /etc/crypttab
# uncomment swap
# <device> LABEL=cryptswap
# <options> = swap,offset=2048,cipher=aes-xts-plain64,size=512

vim /etc/fstab
# replace UUID w/ /dev/mapper/swap

mount -a # no errors?
sudo pacman -S wifi-menu
sudo pacman -S netctl
sudo pacman -S dialog
sudo pacman -S reflector
sudo pacman -S dialog
sudo pacman -S dialog
sudo pacman -S rsync
sudo pacman -S dialog
sudo pacman -S dialog
sudo pacman -S dialog
sudo pacman -S wpa_supplicant
sudo pacman -S ifconfig
sudo pacman -S webkit2gtk
sudo pacman -S gstreamer
sudo pacman -S openssh
sudo pacman -S tllocalmgr
sudo pacman -S tlmgr
sudo pacman -S base-devel
sudo pacman -S --needed base-devel
sudo pacman -S firefox
sudo pacman -S alsa
sudo pacman -S alsamixer
sudo pacman -S alsa-utils
sudo pacman -S mesa
sudo pacman -S xf86-input-synaptics
sudo pacman -S alsa
sudo pacman -S linux-sound-base
sudo pacman -S gedit
sudo pacman -S alsa-sof-firmware
sudo pacman -S alsa-firmware
sudo pacman -S picom
sudo pacman -S xorg-xbacklight
sudo pacman -S fprintd

# Enable Audio
git clone git@github.com:thesofproject/sof-bin.git
cd sof-bin
chmod +x install.sh
sudo ./install.sh v1.9.x/v1.9-rc1
sudo reboot

# Steam
sudo vim /etc/pacman.conf
sudo pacman -Syu
sudo pacman -S steam
sudo pacman -S lib32-mesa
lspci -v | grep -A1 -e VGA -e 3D
pacman -Ss xf86-video
sudo pacman -S xf86-video-intel
sudo pacman -S mesa
sudo pacman -S ttf-liberation
sudo pacman -S lib32-systemd

# Spotify
paru -S spotify
ping archlinux.org
netctl list
ping archlinux.org
spotify --force-device-scale-factor=1.5
ls /usr/share/applications
sudo vim /usr/share/applications/spotify.desktop

# Noctu colorscheme
git clone git://github.com/noahfrederick/vim-noctu.git ~/.vim/bundle/noctu\
mv .vim/bundle/noctu/colors .vim/
rm -rf .vim/bundle/noctu

# AUR packages
paru -S spotify
paru -S expressvpn
paru -S brave-bin
paru -S nerd-fonts-victor-mono
