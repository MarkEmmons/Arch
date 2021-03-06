#!/bin/bash

device="nvme0n1"
device_p1="nvme0n1p1"
device_p2="nvme0n1p2"
device_p3="nvme0n1p3"

set_vbox_device(){

	device="sda"
	device_p1="sda1"
	device_p2="sda2"
	device_p3="sda3"
}

# Clean disk and enable encryption
prepare(){

	# Hide the cursor
	tput civis
	clear

	echo "Preparing to install ArchLinux"
	echo

	source defs.sh
	source progress_bar.sh

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
	sgdisk --zap-all "/dev/${device}"

	# Create partitions. Instructions can be modified in disk.txt
	echo "Creating new partitions"
	gdisk "/dev/${device}" <<< "n


+300M
ef00
n


+4G
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
	cryptsetup luksFormat "/dev/${device_p3}"

	echo "Disk successfully encrypted."
	echo "Unlocking disk..."
	echo -n "$CRYPT" | \
	cryptsetup luksOpen "/dev/${device_p3}" cryptroot
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
	mkfs.fat -F32 "/dev/${device_p1}"
	echo "Formatting swap partition..."
	mkswap "/dev/${device_p2}"
	swapon "/dev/${device_p2}"

	## Use mapper because we want to format the opened partition
	echo "Formatting root partition..."
	#mkfs.btrfs /dev/mapper/cryptroot
	mkfs.btrfs -f "/dev/${device_p3}"

	# Create subvolumes
	echo "Creating subvolumes..."
	#mount /dev/mapper/cryptroot /mnt
	mount "/dev/${device_p3}" /mnt
	cd /mnt
	btrfs subvolume create @
	btrfs subvolume create @home
	cd
	umount /mnt

	# Mount the filesystems
	echo "Mounting filesystem..."
	#mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
	mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ "/dev/${device_p3}" /mnt
	mkdir /mnt/home
	#mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
	mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home "/dev/${device_p3}" /mnt/home
	mkdir /mnt/boot
	mount "/dev/${device_p1}" /mnt/boot

	wait $BAR_ID
}

# Update mirror list for faster install times
update_mirrors(){

	STAT_ARRAY=( "Ranking mirrors"
	"by download speed"
	"Server"
	"INFO"
	"Got new mirror list" )

	# Initialize progress bar
	progress_bar " Updating mirror list" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	echo "Ranking mirrors..."
	reflector --latest 5 --sort rate --verbose --save /etc/pacman.d/mirrorlist
	echo "Got new mirror list!"
	wait $BAR_ID
}

# Refresh mirrors and install the base system
install_base(){

	STAT_ARRAY=( "linux"
	#"linux-firmware"
	#"efibootmgr"
	#"grub-bios"
	#"grub-btrfs"
	#"btrfs-progs"
	"sudo"
	#"vim"
	#"installing base"
	#"installing linux"
	#"installing linux-firmware"
	#"installing efibootmgr"
	#"installing grub-bios"
	#"installing grub-btrfs"
	"installing btrfs-progs" )

	# Initialize progress bar
	progress_bar " Installing base system" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	pacstrap /mnt base base-devel linux linux-firmware efibootmgr grub-bios grub-btrfs btrfs-progs sudo zsh git stow parallel

	## Copy over relevant files
	mkdir -p /mnt/var/log/install
	mv *.log /mnt/var/log/install
	cp progress_bar.sh /mnt/progress_bar.sh
	cp user_scripts.sh /mnt/user_scripts.sh
	cp install_ohmyzsh.sh /mnt/install_ohmyzsh.sh
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
	swapoff "/dev/${device_p2}"
	read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n' < /dev/tty
	tput cnorm
	reboot
}

prepare

tput setaf 7 && tput bold && echo "Installing Arch Linux" && tput sgr0
echo ""
tput setaf 7 && tput bold && echo ":: Running installation scripts..." && tput sgr0

#cache_packages >cache_packages.log 3>&2 2>&1
#sed "s|__CACHE|\"$CACHE\"|" -i chroot.sh

lspci | grep -e VGA -e 3D | grep VMware > /dev/null && set_vbox_device

begin >begin.log 3>&2 2>&1
#encrypt >encrypt.log 3>&2 2>&1
partition >partition.log 3>&2 2>&1
update_mirrors >update_mirrors.log 3>&2 2>&1
install_base >install_base.log 3>&2 2>&1

tput setaf 7 && tput bold && echo ":: Chrooting into new system..." && tput sgr0

chroot_mnt
finish
