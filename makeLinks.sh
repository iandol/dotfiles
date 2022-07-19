#!/usr/bin/env zsh
cd ~
printf "\n\n--->>> Make links in $SHELL, current directory is $(pwd)\n\n"

[[ $(uname -a | grep -i "microsoft") ]] && MOD="WSL"
[[ $(uname -a | grep -Ei "aarch64|armv7") ]] && MOD="RPi"
export PLATFORM=$(uname -s)$MOD
printf "Using $PLATFORM...\n"

XDG_CONFIG_HOME="$HOME/.config"
DF="$HOME/.dotfiles"
CONFIGS="$DF/configs"

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
ln -siv $CONFIGS/default-gems ~/.rbenv
chown $USER ~/.rbenv/default-gems

# Great command prompt
ln -siv $CONFIGS/starship.toml $XDG_CONFIG_HOME
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
if [[ $PLATFORM == 'Darwin' ]]; then
	mkdir -p $HOME/Library/Application\ Support/carapace/specs
	ln -siv $DF/completions/* $HOME/Library/Application\ Support/carapace/specs/
else
	mkdir -p $XDG_CONFIG_HOME/carapace/specs
	ln -siv $DF/completions/* $XDG_CONFIG_HOME/carapace/specs
fi