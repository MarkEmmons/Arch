#!/bin/bash

# Get dotfiles
get_dotfiles(){

	mv /install_ohmyzsh.sh ./install_ohmyzsh.sh
	sh install_ohmyzsh.sh
	rm install_ohmyzsh.sh

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
