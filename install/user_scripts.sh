#!/bin/bash

# Get dotfiles
get_dotfiles(){

	# Retrieve dotfiles
	[[ -f .xinitrc ]] && rm -f .xinitrc
	[[ -f .zshrc ]] && rm -f .zshrc
	git clone https://github.com/MarkEmmons/dotfiles.git

	# Add dotfile scripts to path and make executable
	export PATH=$PATH:$HOME/dotfiles/bin
	chmod a+x $HOME/dotfiles/bin/*

	# "Install" dotfiles
	dot --install
}

cd $HOME

# Get dotfiles
get_dotfiles