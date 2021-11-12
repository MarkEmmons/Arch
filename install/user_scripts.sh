#!/bin/bash

# Get dotfiles
get_dotfiles(){

	# Retrieve dotfiles
	rm .xinitrc
	rm .zshrc
	git clone https://github.com/MarkEmmons/dotfiles.git

	# Add dotfile scripts to path and make executable
	export PATH=$PATH:$HOME/dotfiles/bin
	chmod a+x $HOME/dotfiles/bin/*

	# "Install" dotfiles
	dot --install
}

cd $HOME

echo "Current directory: $pwd"

# Get dotfiles
get_dotfiles