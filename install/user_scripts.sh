#!/bin/bash

# Get dotfiles
get_dotfiles(){

	# Retrieve dotfiles
	[[ -f .xinitrc ]] && rm -f .xinitrc
	[[ -f .zshrc ]] && rm -f .zshrc
    mkdir -p $HOME/workspace
    git clone git@github.com:MarkEmmons/dotfiles.git $HOME/workspace/

	# Add dotfile scripts to path and make executable
	export PATH=$PATH:$HOME/workspace/dotfiles/bin
	chmod a+x $HOME/workspace/dotfiles/bin/*

	# "Install" dotfiles
	dot --install
}

cd $HOME

# Get dotfiles
get_dotfiles
