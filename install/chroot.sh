#!/bin/bash

#HOST=__HOST_NAME
#ROOT=__ROOT_PASS
#USER=__USER_NAME
#PASS=__USER_PASS

#CACHE=__CACHE

# Normal chroot stuff
install_linux(){

	STAT_ARRAY=( "Generating locales"
		"Running mkinitcpio"
		"Running grub-install"
		"Running grub-mkconfig" )
	#"installing wpa_supplicant"
	#"installing vim-runtime"
	#"installing git"
	#"Running post-transaction hooks"
	#"Installing for i386-pc platform"
	#"Generating grub configuration file"
	#"Found linux image: /boot/vmlinuz-linux" )

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
	#echo "FONT=vector-16" > /etc/vconsole.conf || consolefont
	#sed '/^HOOKS=/s|filesystems|encrypt filesystems|' -i /etc/mkinitcpio.conf
	echo -e "\nRunning mkinitcpio"
	mkinitcpio -p linux

	# Install and configure grub
	#pacman --needed --noconfirm --noprogressbar -S zsh parallel wget openssh dialog wpa_actiond wpa_supplicant vim git tmux
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

	USER="mark"
	PASS="mark"

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

	STAT_ARRAY=("installing xorg-server-common"
	"installing xorg-xinit")

	# Initialize progress bar
	progress_bar " Installing Xorg" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	PACKAGES1="alsa-utils mesa xf86-video-{vesa,intel,fbdev} xf86-input-synaptics"
	PACKAGES2="i3 dmenu conky stow xbindkeys feh"
	#PACKAGES3="xorg-{server,xinit,xclock,twm,xprop,xlsfonts,xfontsel}"
	PACKAGES3="xorg-server xorg-xinit xorg-xclock xorg-twm xorg-xprop xorg-xlsfonts xorg-xfontsel"
	#GOHUDEPS="xorg-fonts-{encodings,alias} xorg-font-utils fontconfig"
	GOHUDEPS="xorg-fonts-encodings xorg-fonts-alias xorg-font-utils fontconfig"

	pacman --needed --noconfirm --noprogressbar -S $PACKAGES1
	pacman --needed --noconfirm --noprogressbar -S $PACKAGES2
	pacman --needed --noconfirm --noprogressbar -S $PACKAGES3
	pacman --needed --noconfirm --noprogressbar -S $GOHUDEPS

	echo "exec i3" > /home/$USER/.xinitrc
	[[ -f /home/$USER/.Xauthority ]] && rm /home/$USER/.Xauthority

	wait $BAR_ID
}

build(){

#	"installing cargo" rust is not being installed properly
	STAT_ARRAY=( "installing nodejs"
	"installing cmake"
	"installing virtualbox-host"
	"loop"
	"Waiting on user scripts"
	"We're done" )

	# Initialize progress bar
	progress_bar " Building extras" ${#STAT_ARRAY[@]} "${STAT_ARRAY[@]}" &
	BAR_ID=$!

	# Fetch scripts to be run by $USER
	wget https://raw.github.com/MarkEmmons/ArchInstaller/master/install/user_scripts.sh
	mv user_scripts.sh /usr/bin/user_scripts
	chmod a+x /usr/bin/user_scripts

	# Install additional packages
	DEV_PACKAGES="nodejs npm ctags clang cmake python python2 ruby rust cargo imagemagick"
	WEBDEV_PACKAGES="python-pip gdb yarn mongodb mongodb-tools"
	LANG_PACKAGES="btrfs-progs valgrind scrot htop"
	VM_PACKAGES="docker docker-machine virtualbox virtualbox-host-modules-arch"

	pacman --needed --noconfirm --noprogressbar -S $DEV_PACKAGES

	# Add a wait script and log results separately
	sudo -u $USER user_scripts > /var/log/install/chroot/user_scripts.log 2>&1 &
	PID=$!
	#disown

	pacman --needed --noconfirm --noprogressbar -S $WEBDEV_PACKAGES
	pacman --needed --noconfirm --noprogressbar -S $LANG_PACKAGES

	# Configure docker, for more info consult the wiki
	pacman --needed --noconfirm --noprogressbar -S $VM_PACKAGES
	tee /etc/modules-load.d/loop.conf <<< "loop"
	gpasswd -a $USER docker

	# Wait for user scripts to finish
	echo "Waiting on user scripts"
	wait $PID

	# Install gohu and wal
	#cd /home/$USER/packages/gohufont && pacman --noconfirm --noprogressbar -U *.pkg.tar.xz
	#cd ../wal-git && pacman --noconfirm --noprogressbar -U *.pkg.tar.xz
	#cd /home/$USER && sudo -u $USER wal -i wallpapers/ATAT.jpg
	#cd /

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

install_linux > /var/log/install/chroot/install_linux.log 3>&2 2>&1

# Configure clock.
[[ -f /etc/localtime ]] && rm /etc/localtime
ln -s /usr/share/zoneinfo/US/Central /etc/localtime
hwclock --systohc --utc

#bash </dev/tty

configure_users > /var/log/install/chroot/configure_users.log 3>&2 2>&1
#install_x > /var/log/install/chroot/install_x.log 3>&2 2>&1
#build > /var/log/install/chroot/build.log 3>&2 2>&1

# Enable dhcpcd on VirtualBox
lspci | grep -e VGA -e 3D | grep VMware > /dev/null && enable_dhcpcd > /var/log/install/chroot/enable_dhcpcd.log 3>&2 2>&1

get_runtime
#RUN_TIME=$(get_runtime)
#export RUN_TIME
#export USER
#export HOST
#SHELL="/bin/zsh"
#export SHELL
tput setaf 5 && tput bold && echo "Arch Linux has been installed!" && tput sgr0
#python archey

rm progress_bar.sh
#rm archey
