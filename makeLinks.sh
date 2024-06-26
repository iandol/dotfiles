#!/usr/bin/env bash
cd ~
printf "\n\n--->>> Make links in $SHELL, current directory is $(pwd)\n\n"
MOD=""
[[ $(uname -a | grep -i "microsoft") ]] && MOD="WSL"
[[ $(uname -a | grep -Ei "aarch64|armv7") ]] && MOD="RPi"
[[ $(uname -a | grep -Ei "MINGW64") ]] && MOD="WIN"
export PLATFORM=$(uname -s)$MOD
export XDG_CONFIG_HOME="$HOME/.config"
printf "Using $PLATFORM...\n"

if [[ $MOD == "WIN" ]]; then
	export USER=$USERNAME
	export HOME=$USERPROFILE
	XDG_CONFIG_HOME="$HOME\AppData\Local"
fi

DF="$HOME/.dotfiles"
CONFIGS="$DF/configs"

#few python packages
printf "Do you want to back up existing files? [y / n]:  "
read ans
if [[ $ans == 'y' ]]; then
	[[ -e ~/.bashrc ]] && cp ~/.bashrc ~/.bashrc`date -Iseconds`.bak
	[[ -e ~/.bash_profile ]] && cp ~/.bash_profile ~/.bash_profile`date -Iseconds`.bak
	[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc`date -Iseconds`.bak
	[[ -e ~/.vimrc ]] && cp ~/.vimrc ~/.vimrc`date -Iseconds`.bak
	[[ -e ~/.tmux.conf ]] && cp ~/.tmux.conf ~/.tmux.conf`date -Iseconds`.bak
fi

# My current preferred shell is elvish - https://elv.sh
mkdir -pv $XDG_CONFIG_HOME/elvish
mkdir -pv $XDG_CONFIG_HOME/elvish/lib
ln -siv $DF/rc.elv $XDG_CONFIG_HOME/elvish
ln -siv $DF/cmds.elv $XDG_CONFIG_HOME/elvish/lib
ln -siv $DF/aliases.elv $XDG_CONFIG_HOME/elvish/lib
chown -R $USER $XDG_CONFIG_HOME/elvish

# Default shell on macOS
ln -siv $DF/.zshrc ~
chown $USER ~/.zshrc

# Default on Ubuntu
ln -siv $DF/.bashrc ~
chown $USER ~/.bashrc
ln -siv $DF/.bash_profile ~
chown $USER ~/.bash_profile

# Basic Vim setup, use nvim
mkdir -p $XDG_CONFIG_HOME/nvim
ln -siv $CONFIGS/.vimrc ~
ln -siv $CONFIGS/init.vim $XDG_CONFIG_HOME/nvim/init.vim
chown $USER ~/.vimrc
ln -siv $DF/.vim ~
chown -R $USER ~/.vim
chown -R $USER $XDG_CONFIG_HOME/nvim

# Ruby setup
ln -siv $CONFIGS/.rubocop.yml ~
chown $USER ~/.rubocop.yml
mkdir -p .rbenv
ln -siv $CONFIGS/default-gems ~/.rbenv
chown $USER ~/.rbenv/default-gems

# Great command prompt
if [[ $PLATFORM == 'LinuxRPi' ]]; then
	ln -siv $CONFIGS/starshiprpi.toml $XDG_CONFIG_HOME/starship.toml
else
	ln -siv $CONFIGS/starship.toml $XDG_CONFIG_HOME
fi
chown $USER $XDG_CONFIG_HOME/starship.toml

# Used on macOS and Linux
mkdir -p $XDG_CONFIG_HOME/kitty
ln -siv $CONFIGS/kitty.conf $XDG_CONFIG_HOME/kitty
chown -R $USER $XDG_CONFIG_HOME/kitty

# Used on RPi
ln -siv $CONFIGS/alacritty.yml $XDG_CONFIG_HOME
chown $USER $XDG_CONFIG_HOME/alacritty.yml

# tmux setup
ln -siv $CONFIGS/.tmux.conf ~
chown $USER ~/.tmux.conf

# carapace setup
mkdir -p $XDG_CONFIG_HOME/carapace/specs
ln -siv $DF/completions/* $XDG_CONFIG_HOME/carapace/specs
