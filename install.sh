#!/bin/bash
printf '\e[36m'
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
printf '\nCopying zsh theme if oh-my-zsh is installed...\n'
if [ -d ~/.oh-my-zsh/ ]; then
	cp -f ~/.dotfiles/*-theme ~/.oh-my-zsh/custom/
	printf 'Themes copied over...\n'
else
	printf 'Installing .oh-my-zsh\n'
	git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
	cp -f ~/.dotfiles/*-theme ~/.oh-my-zsh/custom/
	printf 'Themes copied over...\n'
fi
echo 'Do you want to set up OS X defaults? (yes / no)'
read ans
if [ $ans == 'yes' ]; then
	echo 'Enter password for setup command:'
	sudo sh ~/.dotfiles/osx.sh
fi
printf 'Done...\n'
printf '\e[m'
