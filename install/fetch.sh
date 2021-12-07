# Last calculated hashes
INSTALL='1fcedea9844100d49b406c0ec6bf709fe4adf2f9cf13965e039184c8f3fb0b8f9248181ba09b7d9ba5587c7ec028e58b25ef2ee9a21a390904ba9eb57b2dc922'
DEFS='0244fa2d23787c8a2ff45346323d7a41f561350c26f35740791ee73856a62401a2192aa0768812dc43411a8bdde38a8ec819ef6d19022c4e838e16943c9821e1'
CHROOT='aa47c9f72b74dd80627dc9d1215436f42b643b20565c25d4a0c80d36afc26adbaebf421d95845e4a39262058d34eaa3a6b39fe117654feb497acad683d182e49'
PROGRESS_BAR='34842a5ecc23cbde6eea924a62c7181e4348a972f9be845a5cfd1c2d479d1621c0cf48c96a0b87f0e3cc0d520a6b705e6ae091ce7647236a5d8085d64ad0d21b'
USER_SCRIPTS='300a6b525271b9fb6b00339ada36beb3b3fcaafafa5a8e376f9771268d3b2e3c25fa8bcda6a3594426989ddc45d4e9deee2653b22aa107ffa6ea343c1320a71e'
OHMYZSH='42cc12ab9187e97e39ea6078be103c6cfafdeaa823bfab102bb26ccd17aa4dbd365d43fc364b85a117110833a90654d9955948164bb75012182e770c9e310745'

# Get your stuff
curl -LJO https://raw.github.com/MarkEmmons/Arch/master/install.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.github.com/MarkEmmons/Arch/master/install/defs.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.github.com/MarkEmmons/Arch/master/install/chroot.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.github.com/MarkEmmons/Arch/master/install/progress_bar.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.github.com/MarkEmmons/Arch/master/install/user_scripts.sh > /dev/null 3>&2 2>&1

curl -LJo install_ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > /dev/null 3>&2 2>&1

# install.sh
if [[ $INSTALL = $(sha512sum install.sh | awk '{ print $1 }') ]]; then
	tput setaf 2 && tput bold && echo "Downloaded install.sh - $(sha512sum install.sh | awk '{ print $1 }')" && tput sgr0
else
	tput setaf 1 && tput bold && echo "Downloaded install.sh - $(sha512sum install.sh | awk '{ print $1 }')" && tput sgr0
fi

# defs.sh
if [[ $DEFS = $(sha512sum defs.sh | awk '{ print $1 }') ]]; then
	tput setaf 2 && tput bold && echo "Downloaded defs.sh - $(sha512sum defs.sh | awk '{ print $1 }')" && tput sgr0
else
	tput setaf 1 && tput bold && echo "Downloaded defs.sh - $(sha512sum defs.sh | awk '{ print $1 }')" && tput sgr0
fi

# chroot.sh
if [[ $CHROOT = $(sha512sum chroot.sh | awk '{ print $1 }') ]]; then
	tput setaf 2 && tput bold && echo "Downloaded chroot.sh - $(sha512sum chroot.sh | awk '{ print $1 }')" && tput sgr0
else
	tput setaf 1 && tput bold && echo "Downloaded chroot.sh - $(sha512sum chroot.sh | awk '{ print $1 }')" && tput sgr0
fi

# progress_bar.sh
if [[ $PROGRESS_BAR = $(sha512sum progress_bar.sh | awk '{ print $1 }') ]]; then
	tput setaf 2 && tput bold && echo "Downloaded progress_bar.sh - $(sha512sum progress_bar.sh | awk '{ print $1 }')" && tput sgr0
else
	tput setaf 1 && tput bold && echo "Downloaded progress_bar.sh - $(sha512sum progress_bar.sh | awk '{ print $1 }')" && tput sgr0
fi

# user_scripts.sh
if [[ $USER_SCRIPTS = $(sha512sum user_scripts.sh | awk '{ print $1 }') ]]; then
	tput setaf 2 && tput bold && echo "Downloaded user_scripts.sh - $(sha512sum user_scripts.sh | awk '{ print $1 }')" && tput sgr0
else
	tput setaf 1 && tput bold && echo "Downloaded user_scripts.sh - $(sha512sum user_scripts.sh | awk '{ print $1 }')" && tput sgr0
fi

# install_ohmyzsh.sh
if [[ $OHMYZSH = $(sha512sum install_ohmyzsh.sh | awk '{ print $1 }') ]]; then
	tput setaf 2 && tput bold && echo "Downloaded install_ohmyzsh.sh - $(sha512sum install_ohmyzsh.sh | awk '{ print $1 }')" && tput sgr0
else
	tput setaf 1 && tput bold && echo "Downloaded install_ohmyzsh.sh - $(sha512sum install_ohmyzsh.sh | awk '{ print $1 }')" && tput sgr0
fi
