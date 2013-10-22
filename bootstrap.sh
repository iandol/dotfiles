#!/bin/bash
printf '\e[36m'

printf 'Let us bootstrap Homebrew if not present ... '
if [ -f /usr/local/bin/brew ]; then
	printf 'Homebrew is present!\n'
else
	ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
	printf 'Homebrew installed...\n'
	brew install git figlet jq
fi

printf 'Let us bootstrap .dotfiles if not present ... '
if [ -d ~/.dotfiles/ ]; then
	printf ' .dotfiles are present! \n'
else	
	git clone https://github.com/iandol/dotfiles.git .dotfiles
	printf 'we cloned a new .dotfiles...\n'
fi

printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
ln -siv ~/.dotfiles/.zshrc ~
ln -siv ~/.dotfiles/.bashrc ~
ln -siv ~/.dotfiles/.bash_profile ~
ln -siv ~/.dotfiles/.vimrc ~
ln -siv ~/.dotfiles/.vim/ ~/.vim
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

printf 'Linking some bin files in ~/bin/: \n'
printf '\e[32m'
if [ -d ~/bin/ ]; then
	ln -sv ~/.dotfiles/bin/* ~/bin
else
	mkdir ~/bin/
	ln -sv ~/.dotfiles/bin/* ~/bin
fi
printf '\e[36m\n\n'

printf 'Do you want to set up OS X defaults? (y / n):  '
read ans
if [ $ans == 'y' ]; then
	echo 'Enter password for setup command:'
	sudo echo -n "..."
	zsh ~/.dotfiles/osx.sh
fi

if [ -f $(which git) ]; then
	printf 'Setting some GIT defaults...\n'
	git config --global alias.last 'log -1 HEAD'
	git config --global alias.unstage 'reset HEAD --'
	git config --global alias.st status
	git config --global alias.br branch
	git config --global alias.co checkout
	git config --global alias.dt difftool
	git config --global difftool.prompt false
	git config --global color.ui always
	git config --global color.branch true
	git config --global color.diff true
	git config --global color.grep true
	git config --global color.interactive true
	git config --global color.status true
else
	printf 'GIT is not installed, use command line tools or install homebrew...\n'
fi
printf '\n\n--->>> All Done...\n'
printf '\e[m'
