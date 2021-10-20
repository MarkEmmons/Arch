#!/bin/bash

# Clean disk and enable encryption
prepare(){

	# Hide the cursor
	tput civis
	clear

	echo "Preparing to install ArchLinux"
	echo

	# Fetch some extra stuff
	curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/defs.sh > /dev/null 3>&2 2>&1
	source defs.sh
	source progress_bar.sh

	curl -LJO "$SRC$CHROOT" > /dev/null 3>&2 2>&1
	curl -LJO "$SRC$PBAR" > /dev/null 3>&2 2>&1
	#curl -LJO "$SRC$ARCHEY" > /dev/null 3>&2 2>&1

	# Dissalow screen blanking for installation
	setterm -blank 0

	# Set time for time-keeping
	rm /etc/localtime
	ln -s /usr/share/zoneinfo/US/Central /etc/localtime
	hwclock --systohc --utc

	#uinfo_dialog

	# Echo start time
	date > time.log
}

begin(){

	STAT_ARRAY=( "Zapping former partitions"
	"Creating new partitions"
	"Done" )

	# Initialize progress bar
	progress_bar " Getting started" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

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
	wait $BAR_ID
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

	# Enable encryption module
	echo "Enabling encryption"
	#modprobe -a dm-mod dm_crypt

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

	STAT_ARRAY=( "Formatting boot partition"
	"Formatting swap partition"
	"Formatting root partition"
	"Creating subvolumes"
	"Mounting filesystem" )

	# Initialize progress bar
	progress_bar " Partitioning" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	# Format the filesystems on each logical volume
	echo "Formatting boot partition..."
	mkfs.fat -F32 /dev/sda1
	echo "Formatting swap partition..."
	mkswap /dev/sda2
	swapon /dev/sda2

	## Use mapper because we want to format the opened partition
	echo "Formatting root partition..."
	#mkfs.btrfs /dev/mapper/cryptroot
	mkfs.btrfs -f /dev/sda3

	# Create subvolumes
	echo "Creating subvolumes..."
	#mount /dev/mapper/cryptroot /mnt
	mount /dev/sda3 /mnt
	cd /mnt
	btrfs subvolume create @
	btrfs subvolume create @home
	cd
	umount /mnt

	# Mount the filesystems
	echo "Mounting filesystem..."
	#mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
	mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ /dev/sda3 /mnt
	mkdir /mnt/home
	#mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
	mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home /dev/sda3 /mnt/home
	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot

	wait $BAR_ID
}

# Update mirror list for faster install times
update_mirrors(){

	STAT_ARRAY=( "Ranking mirrors"
	"Got new mirror list" )

	# Initialize progress bar
	progress_bar " Updating mirror list" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	echo "Ranking mirrors..."
	reflector --latest 15 --sort rate --save /etc/pacman.d/mirrorlist
	echo "Got new mirror list!"
	wait $BAR_ID
}

# Refresh mirrors and install the base system
install_base(){

	STAT_ARRAY=( "base"
	"linux"
	"linux-firmware"
	"efibootmgr"
	"grub-bios"
	"grub-btrfs"
	"btrfs-progs"
	"sudo"
	"vim"
	"installing base"
	"installing linux"
	"installing linux-firmware"
	"installing efibootmgr"
	"installing grub-bios"
	"installing grub-btrfs"
	"installing btrfs-progs"
	"installing sudo"
	"installing vim" )

	# Initialize progress bar
	progress_bar " Installing base system" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	pacstrap /mnt base linux linux-firmware efibootmgr grub-bios grub-btrfs btrfs-progs sudo vim

	## Copy over relevant files
	mkdir -p /mnt/var/log/install
	mv *.log /mnt/var/log/install
	#mv archey /mnt/archey
	cp progress_bar.sh /mnt/progress_bar.sh
	cp /etc/zsh/zshrc /mnt/root/.zshrc

	# Generate an fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	wait $BAR_ID
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
	#reboot
}

prepare

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
