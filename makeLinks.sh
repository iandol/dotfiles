#!/bin/bash
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
ln -siv $DF/rc.elv $XDG_CONFIG_HOME/elvish
ln -siv $DF/cmds.elv $XDG_CONFIG_HOME/elvish/lib
ln -siv $DF/aliases.elv $XDG_CONFIG_HOME/elvish/lib
chown $USER -R $XDG_CONFIG_HOME/elvish

# Default on macOS
ln -siv $DF/.zshrc ~
chown $USER ~/.zshrc

# Default on Ubuntu
ln -siv $DF/.bashrc ~
chown $USER ~/.bashrc
ln -siv $DF/.bash_profile ~
chown $USER ~/.bash_profile

# Basic Vim setup
ln -siv $DF/.vimrc ~
chown $USER ~/.vimrc
ln -siv $DF/.vim ~/.vim
chown -R $USER ~/.vim

# Ruby setup
ln -siv $CONFIGS/.rubocop.yml ~
chown $USER ~/.rubocop.yml
ln -siv $CONFIGS/default-gems ~/.rbenv/
chown $USER ~/.rbenv/default-gems

# Great command prompt
ln -siv $CONFIGS/starship.toml ~/.config/
chown $USER $XDG_CONFIG_HOME/starship.toml

# Used on RPi
ln -siv $CONFIGS/alacritty.yml ~/.config/
chown $USER $XDG_CONFIG_HOME/alacritty.yml

# tmux setup
ln -siv $CONFIGS/.tmux.conf ~
chown $USER ~/.tmux.conf