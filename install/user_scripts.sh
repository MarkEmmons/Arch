#!/bin/bash

# Get dotfiles
get_dotfiles(){

	lspci | grep -e VGA -e 3D | grep VMware > /dev/null && curl -LJO https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > /dev/null 3>&2 2>&1
	sh install.sh

	# Retrieve dotfiles
	[[ -f .xinitrc ]] && rm -f .xinitrc
	[[ -f .zshrc ]] && rm -f .zshrc
	mkdir -p $HOME/workspace
	git clone https://github.com/MarkEmmons/dotfiles.git $HOME/workspace/dotfiles

	# Add dotfile scripts to path and make executable
	export PATH=$PATH:$HOME/workspace/dotfiles/bin
	chmod a+x $HOME/workspace/dotfiles/bin/*

	# "Install" dotfiles
	dot --install
}

cd $HOME

# Get dotfiles
get_dotfiles
