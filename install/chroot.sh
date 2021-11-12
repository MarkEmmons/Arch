#!/bin/bash

#HOST=__HOST_NAME
#ROOT=__ROOT_PASS
#USER=__USER_NAME
#PASS=__USER_PASS

#CACHE=__CACHE

HOST="Arch"
ROOT="root"
USER="mark"
PASS="mark"

# Normal chroot stuff
install_linux(){

	STAT_ARRAY=( "Generating locales"
		"Running mkinitcpio"
		"Running grub-install"
		"Running grub-mkconfig" )

	# Initialize progress bar
	progress_bar " Installing Linux" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	# Generate locales
	sed 's|#en_US|en_US|' -i /etc/locale.gen
	locale-gen

	# Export locales
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	export LANG=en_US.UTF-8

	# Add host
	echo "$HOST" > /etc/hostname

	# Create hosts
	echo "127.0.0.1 localhost" >> /etc/hosts
	echo "::1       localhost" >> /etc/hosts
	echo "127.0.1.1 $HOST.localdomain $HOST" >> /etc/hosts

	# Install Linux
	sed '/^MODULES=/s|()|(btrfs)|' -i /etc/mkinitcpio.conf
	#sed '/^HOOKS=/s|filesystems|encrypt filesystems|' -i /etc/mkinitcpio.conf
	echo -e "\nRunning mkinitcpio"
	mkinitcpio -p linux

	# Install and configure grub
	echo -e "\nRunning grub-install"
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	echo -e "\nRunning grub-mkconfig"

	#CR_UUID=$(blkid | grep cryptroot | awk '{ print $2 }' | sed 's|"||g')
	#sed "/^GRUB_CMDLINE_LINUX_DEFAULT=/s|quiet|quiet cryptdevice=${CR_UUID}:cryptroot root=/dev/mapper/cryptroot|" -i /etc/default/grub

	grub-mkconfig -o /boot/grub/grub.cfg

	wait $BAR_ID
}

# Create user and add some passwords
configure_users(){

	STAT_ARRAY=( "Setting root password"
		"Root password set"
		"Changing shell for root"
		"Shell changed"
		"Adding new user"
		"Setting user password"
		"Adding user to sudoers"
		"New user created" )

	# Initialize progress bar
	progress_bar " Configuring users" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	# Choose password for root and change default shell to zsh
	echo "Setting root password..."
	echo "root:$ROOT" | chpasswd
	unset $ROOT
	echo "Root password set"

	echo "Changing shell for root..."
	chsh -s /bin/zsh
	echo "Shell changed"

	# Give new user root-privileges
	echo "Adding new user..."
	useradd -m -G wheel -s /bin/zsh $USER
	cp /root/.zshrc /home/$USER/.zshrc
	echo "Setting user password..."
	echo "$USER:$PASS" | chpasswd
	unset $PASS
	echo "Adding user to sudoers..."
	sed "s/^root ALL=(ALL) ALL/root ALL=(ALL) ALL\n$USER ALL=(ALL) ALL/" -i /etc/sudoers
	echo "New user created."

	wait $BAR_ID
}

# Install X Window System
install_x(){

	STAT_ARRAY=("Installing xorg"
		"Installing bspwm configs"
		"Generating xinitrc")

	# Initialize progress bar
	progress_bar " Installing Xorg" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	echo "Installing xorg..."
	pacman --needed --noconfirm --noprogressbar -S xorg xorg-xinit bspwm sxhkd dmenu xterm feh zsh

	mkdir -p /home/$USER/.config/bspwm/
	mkdir -p /home/$USER/.config/sxhkd/

	echo "Installing bspwm configs..."
	install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc /home/$USER/.config/bspwm/bspwmrc
	install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc /home/$USER/.config/sxhkd/sxhkdrc

	sed 's|urxvt|xterm|' -i /home/$USER/.config/sxhkd/sxhkdrc

	echo "Generating xinitrc..."
	echo "sxhkd &" > /home/$USER/.xinitrc
	echo "exec bspwm" >> /home/$USER/.xinitrc

	[[ -f /home/$USER/.Xauthority ]] && rm /home/$USER/.Xauthority

	wait $BAR_ID
}

build(){

	STAT_ARRAY=( "Running user scripts"
		"Installing gcc"
		"Installing rust"
		"Installing command line tools"
		"Installing additional tools"
		"Waiting on user scripts"
		"We're done" )

	# Initialize progress bar
	progress_bar " Building extras" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!


	# Fetch scripts to be run by $USER
	echo "Running user scripts..."
	curl -LJO https://raw.github.com/MarkEmmons/Arch/master/install/user_scripts.sh
	mv user_scripts.sh /usr/bin/user_scripts
	chmod a+x /usr/bin/user_scripts

	# Add a wait script and log results separately
	sudo -u $USER user_scripts > /var/log/install/chroot/user_scripts.log 2>&1 &
	PID=$!


	# Install C/C++ Tools
	echo "Installing gcc..."
	pacman --needed --noconfirm --noprogressbar -S gcc gdb valgrind


	# Install Rust Tools
	echo "Installing rust..."
	pacman --needed --noconfirm --noprogressbar -S rust


	# Install LaTex Tools
	pacman --needed --noconfirm --noprogressbar -S zathura zathura-pdf-mupdf


	# Install Console Tools
	echo "Installing command line tools..."
	pacman --needed --noconfirm --noprogressbar -S vim git tmux


	# Install Other Tools
	echo "Installing additional tools..."
	pacman --needed --noconfirm --noprogressbar -S stow luakit parallel imagemagick scrot htop

	## Configure docker, for more info consult the wiki
	#pacman --needed --noconfirm --noprogressbar -S docker docker-machine
	#tee /etc/modules-load.d/loop.conf <<< "loop"
	#gpasswd -a $USER docker

	# Wait for user scripts to finish
	echo "Waiting on user scripts"
	wait $PID

	echo "We're done"

	# Don't need these anymore
	rm /usr/bin/user_scripts

	wait $BAR_ID
}

get_runtime(){

	# Get time at start and completion of script
	H_START=$(cat /var/log/install/time.log | sed -e 's|:| |g' | awk '{print $4}')
	M_START=$(cat /var/log/install/time.log | sed -e 's|:| |g' | awk '{print $5}')
	S_START=$(cat /var/log/install/time.log | sed -e 's|:| |g' | awk '{print $6}')

	H_END=$(date | sed -e 's|:| |g' | awk '{print $4}')
	M_END=$(date | sed -e 's|:| |g' | awk '{print $5}')
	S_END=$(date | sed -e 's|:| |g' | awk '{print $6}')

	# Strip leading zeros
	H_START=$((10#$H_START))
	M_START=$((10#$M_START))
	S_START=$((10#$S_START))

	H_END=$((10#$H_END))
	M_END=$((10#$M_END))
	S_END=$((10#$S_END))

	if [[ $H_START -gt $H_END ]]; then
		H_END=$(($H_END + 24))
	fi

	if [[ $M_START -gt $M_END ]]; then
		H_END=$(($H_END - 1))
		M_END=$(($M_END + 60))
	fi

	if [[ $S_START -gt $S_END ]]; then
		M_END=$(($M_END - 1))
		S_END=$(($S_END + 60))
	fi

	H_RUN=$(($H_END - $H_START))
	M_RUN=$(($M_END - $M_START))
	S_RUN=$(($S_END - $S_START))

	echo "${H_RUN} hours: ${M_RUN}.${S_RUN}"
}

enable_dhcpcd() {

	STAT_ARRAY=( "dhcpcd" )

	# Initialize progress bar
	progress_bar " Enabling dhcpcd" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	# For VirtualBox
	pacman --needed --noconfirm --noprogressbar -S dhcpcd
	systemctl enable dhcpcd.service

	wait $BAR_ID
}

# Main
mkdir -p /var/log/install/chroot
source progress_bar.sh

# Configure clock.
[[ -f /etc/localtime ]] && rm /etc/localtime
ln -s /usr/share/zoneinfo/US/Central /etc/localtime
hwclock --systohc --utc

install_linux > /var/log/install/chroot/install_linux.log 3>&2 2>&1
install_x > /var/log/install/chroot/install_x.log 3>&2 2>&1
configure_users > /var/log/install/chroot/configure_users.log 3>&2 2>&1
build > /var/log/install/chroot/build.log 3>&2 2>&1

# Enable dhcpcd on VirtualBox
lspci | grep -e VGA -e 3D | grep VMware > /dev/null && enable_dhcpcd > /var/log/install/chroot/enable_dhcpcd.log 3>&2 2>&1

get_runtime
tput setaf 5 && tput bold && echo "Arch Linux has been installed!" && tput sgr0

rm progress_bar.sh
