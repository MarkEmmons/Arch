#!/bin/bash

#curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/defs.sh
#source defs.sh

# Clean disk and enable encryption
prepare(){

	# Hide the cursor
	tput civis
	clear

	echo "Preparing to install ArchLinux"
	echo

	# Fetch some extra stuff
	#curl -LJO "$SRC$CHROOT"
	curl -LJO "https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/chroot.sh"
	#curl -LJO "$SRC$PBAR"
	#curl -LJO "$SRC$ARCHEY"

	# Dissalow screen blanking for installation
	setterm -blank 0

	# Set time for time-keeping
	#rm /etc/localtime
	#ln -s /usr/share/zoneinfo/US/Central /etc/localtime
	#hwclock --systohc --utc

	#uinfo_dialog

	# Echo start time
	#date > time.log
}

begin(){

	#STAT_ARRAY=( "Enabling encryption"
	#"Zapping former partitions"
	#"Creating new partitions"
	#"Done" )

	# Initialize progress bar
	#progress_bar " Getting started" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	#BAR_ID=$!

	# Enable encryption module
	echo "Enabling encryption"
	#modprobe -a dm-mod dm_crypt

	# Zap any former entry
	echo "Zapping former partitions"
	sgdisk --zap-all /dev/sda

	# Create partitions. Instructions can be modified in disk.txt
	echo "Creating new partitions"
	gdisk /dev/sda <<< "n


+300M
ef00
n


+1G
8200
n




w
Y
"

	echo "Done"
	#wait $BAR_ID
}

# Encrypt the lvm partition then un-encrypt for partitioning
encrypt(){

	#STAT_ARRAY=( "Encrypting disk"
	#"Disk successfully encrypted"
	#"Unlocking disk"
	#"Disk successfully unlocked" )

	# Initialize progress bar
	#progress_bar " Encrypting disk" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	#BAR_ID=$!

	echo "Encrypting disk..."
	echo -n "$CRYPT" | \
	cryptsetup luksFormat /dev/sda3

	echo "Disk successfully encrypted."
	echo "Unlocking disk..."
	echo -n "$CRYPT" | \
	cryptsetup luksOpen /dev/sda3 cryptroot
	unset CRYPT
	echo "Disk successfully unlocked."
	echo
	#wait $BAR_ID
}

# Partition
partition(){

	#STAT_ARRAY=( "Physical volume \"/dev/mapper/lvm\" successfully created."
	#"Logical volume \"homevol\" created."
	#"/dev/mapper/ArchLinux-rootvol"
	#"/dev/mapper/ArchLinux-homevol"
	#"/dev/mapper/ArchLinux-pool"
	#"Creating filesystem with"
	#"Allocating group tables:"
	#"Setting up swapspace version" )

	# Initialize progress bar
	#progress_bar " Partitioning" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	#BAR_ID=$!

	# Format the filesystems on each logical volume
	mkfs.fat -F32 /dev/sda1
	mkswap /dev/sda2
	swapon /dev/sda2

	## Use mapper because we want to format the opened partition
	mkfs.btrfs /dev/mapper/cryptroot

	# Create subvolumes
	mount /dev/mapper/cryptroot /mnt
	cd /mnt
	btrfs subvolume create @
	btrfs subvolume create @home
	cd
	umount /mnt

	# Mount the filesystems
	mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
	mkdir /mnt/home
	mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot

	#wait $BAR_ID
}

# Update mirror list for faster install times
update_mirrors(){

	#STAT_ARRAY=( "Ranking mirrors..."
	#"Got armrr"
	#"Running armrr..."
	#"Got new mirror list" )

	# Initialize progress bar
	#progress_bar " Updating mirror list" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	#BAR_ID=$!

	reflector --latest 15 --sort rate --save /etc/pacman.d/mirrorlist
	echo "Got new mirror list"
	#wait $BAR_ID
}

# Refresh mirrors and install the base system
install_base(){

	#STAT_ARRAY=( "Creating install root at"
	#"linux-api-headers"
	#"pambase"
	#"dhcpcd"
	#"man-pages"
	#"git"
	#"python2"
	#"http-parser"
	#"sudo"
	#"xterm"
	#"nodejs"
	#"feh"
	#"members in group base"
	#"installing linux-api-headers"
	#"installing dhcpcd"
	#"installing man-pages"
	#"installing pacman"
	#"installing autoconf"
	#"installing automake"
	#"installing binutils"
	#"installing bison"
	#"installing fakeroot"
	#"installing gcc"
	#"installing guile"
	#"installing make"
	#"installing patch"
	#"may fail on some machines"
	#"Updating system user accounts"
	#"Rebuilding certificate stores" )

	## Initialize progress bar
	#progress_bar " Installing base system" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	#BAR_ID=$!

	#pacman -Syy
	pacstrap /mnt base linux linux-firmware efibootmgr grub-bios grub-btrfs btrfs-progs sudo vim

	## Copy over relevant files
	#mkdir /mnt/var/log/install
	#mv *.log /mnt/var/log/install
	#mv archey /mnt/archey
	#cp progress_bar.sh /mnt/progress_bar.sh
	#cp /etc/zsh/zshrc /mnt/root/.zshrc

	# Generate an fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	#wait $BAR_ID
}

# Create fstab and chroot into the new system
chroot_mnt(){
	arch-chroot /mnt /bin/bash < chroot.sh
}

# Unmount and reboot
finish(){
	umount -R /mnt
	swapoff /dev/sda2
	read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n' < /dev/tty
	tput cnorm
	reboot
}

prepare

# See if we can put this in prepare
#source progress_bar.sh

tput setaf 7 && tput bold && echo "Installing Arch Linux" && tput sgr0
echo ""
tput setaf 7 && tput bold && echo ":: Running installation scripts..." && tput sgr0

#cache_packages >cache_packages.log 3>&2 2>&1

sed "s|CACHE_VAL_TO_BE|\"$CACHE\"|" -i chroot.sh

begin >begin.log 3>&2 2>&1
#encrypt >encrypt.log 3>&2 2>&1
partition >partition.log 3>&2 2>&1
update_mirrors >update_mirrors.log 3>&2 2>&1
install_base >install_base.log 3>&2 2>&1

tput setaf 7 && tput bold && echo ":: Chrooting into new system..." && tput sgr0

chroot_mnt
finish
