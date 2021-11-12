#!/bin/bash

# Get dotfiles
get_dotfiles(){

	# Retrieve dotfiles
	rm -f .xinitrc
	rm -f .zshrc
	git clone https://github.com/MarkEmmons/dotfiles.git

	# Add dotfile scripts to path and make executable
	export PATH=$PATH:$HOME/dotfiles/bin
	chmod a+x $HOME/dotfiles/bin/*

	# "Install" dotfiles
	dot --install
	date
}

cd $HOME

# Get dotfiles
get_dotfiles