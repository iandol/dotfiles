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
if [ -d ~/.oh-my-zsh/custom ]; then
	cp -f ~/.dotfiles/*-theme ~/.oh-my-zsh/custom/
	printf 'Themes copied over...\n'
else
	printf 'Couldnt find .oh-my-zsh\n'
fi
printf 'Done...\n'
printf '\e[m'
