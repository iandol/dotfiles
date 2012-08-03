#!/bin/bash
printf '\e[36m'
printf 'Let us bootstrap .dotfiles if not present... '
if [ -d ~/.dotfiles ]; then
	git clone https://github.com/iandol/dotfiles.git .dotfiles
	printf 'We cloned a new .dotfiles...\n'
fi
printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
ln -siv ~/.dotfiles/.zshrc ~
ln -siv ~/.dotfiles/.bashrc ~
ln -siv ~/.dotfiles/.bash_profile ~
ln -siv ~/.dotfiles/.vimrc ~
ln -siv ~/.dotfiles/.vim ~
printf '\e[36m'
if [ -d ~/.oh-my-zsh/ ]; then
	printf '\nCopying zsh theme as oh-my-zsh is installed...\n'
	cp -f ~/.dotfiles/*-theme ~/.oh-my-zsh/custom/
	printf 'Themes copied over...\n'
else
	printf 'Installing .oh-my-zsh ... \n'
	git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
	cp -f ~/.dotfiles/*-theme ~/.oh-my-zsh/custom/
	printf ' and themes copied over...\n'
fi
echo 'Do you want to set up OS X defaults? (y / n)'
read ans
if [ $ans == 'y' ]; then
	echo 'Enter password for setup command:'
	sudo echo -n "..."
	zsh ~/.dotfiles/osx.sh
fi
printf 'Done...\n'
printf '\e[m'
