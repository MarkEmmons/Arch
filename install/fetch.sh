# Last calculated hashes
INSTALL='6fa257edf5690dd7c517db16ed8aeab3a3ba506e9513b9b127716191907cd625bb74bbc35e0e2b4e4f7c5ac471c22006254131a71a51d9d5b4bac932720a6f19'
DEFS='5a2adf14ff3f344d8bf4bf8a5b41728316572ec070199e701d35e9db96f9a3429e54a9181af934acf81ca9250e1ce1d75ea310b1d7a9984e92f662c03060c7bb'
CHROOT='b42faefa42f9e7164a7cda3905de346e7d0b743ca973993ad3ea880e57fd763716f30872073a369b09f511cc06ad93516b11f89a9c9a6aaa9ab270fad61b06a8'
PROGRESS_BAR='244494eda475cc65d1cc2c704d633585e2d6d18de1c3a8c9f2b0d73b39608434d345e0ae26f41074588da31cbae09fe2e52054ca3925d604f95d15d349e72fa5'
USER_SCRIPTS='ecba402466b49895763be61bad7dc8e149c1db2ccedbdd18190613179871f632235e978061bafd43f9e8b43f33eeaf3baf3009c24fa650b66c25bd71b7c43b75'
OHMYZSH='42cc12ab9187e97e39ea6078be103c6cfafdeaa823bfab102bb26ccd17aa4dbd365d43fc364b85a117110833a90654d9955948164bb75012182e770c9e310745'

# Get your stuff
curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/install.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/defs.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/chroot.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/progress_bar.sh > /dev/null 3>&2 2>&1
curl -LJO https://raw.githubusercontent.com/MarkEmmons/Arch/master/install/user_scripts.sh > /dev/null 3>&2 2>&1

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
