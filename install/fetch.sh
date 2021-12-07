# Last calculated hashes
INSTALL='6FA257EDF5690DD7C517DB16ED8AEAB3A3BA506E9513B9B127716191907CD625BB74BBC35E0E2B4E4F7C5AC471C22006254131A71A51D9D5B4BAC932720A6F19'
DEFS='5A2ADF14FF3F344D8BF4BF8A5B41728316572EC070199E701D35E9DB96F9A3429E54A9181AF934ACF81CA9250E1CE1D75EA310B1D7A9984E92F662C03060C7BB'
CHROOT='B42FAEFA42F9E7164A7CDA3905DE346E7D0B743CA973993AD3EA880E57FD763716F30872073A369B09F511CC06AD93516B11F89A9C9A6AAA9AB270FAD61B06A8'
PROGRESS_BAR='244494EDA475CC65D1CC2C704D633585E2D6D18DE1C3A8C9F2B0D73B39608434D345E0AE26F41074588DA31CBAE09FE2E52054CA3925D604F95D15D349E72FA5'
USER_SCRIPTS='ECBA402466B49895763BE61BAD7DC8E149C1DB2CCEDBDD18190613179871F632235E978061BAFD43F9E8B43F33EEAF3BAF3009C24FA650B66C25BD71B7C43B75'
OHMYZSH='42CC12AB9187E97E39EA6078BE103C6CFAFDEAA823BFAB102BB26CCD17AA4DBD365D43FC364B85A117110833A90654D9955948164BB75012182E770C9E310745'

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
