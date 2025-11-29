#!/usr/bin/env bash
# custom script to set up symlinks, deprecated as I now use rotz
# Usage: ./makeLinks.sh [backup]
# If 'backup' is provided as an argument, existing files will be backed up with a timestamp.
cd ~ || exit

if [ -z "$1" ]; then
	backup="false"
else
	backup="true"
fi

printf "\n\n--->>> Make Links for %s, current directory is %s\n\n" "$USER" "$(pwd)"

MOD=""
uname -a | grep -iq "microsoft" && MOD="WSL"
uname -a | grep -iq "aarch64|armv7" && MOD="RPi"
uname -a | grep -iq "MINGW64"&& MOD="WIN"
PLATFORM=$(uname -s)$MOD
export XDG_CONFIG_HOME="$HOME/.config"
printf "Using %s...\n" "$PLATFORM"

if [[ $MOD == "WIN" ]]; then
	export USER=$USERNAME
	export HOME=$USERPROFILE
	XDG_CONFIG_HOME="$HOME\AppData\Local"
fi

DF="$HOME/.dotfiles"
CONFIGS="$DF"

if [ $backup == "true" ]; then
	printf "Do you want to back up existing files? [y / n]:  "
	read -r ans
	if [[ $ans == 'y' ]]; then
		[[ -e ~/.bashrc ]] && cp ~/.bashrc ~/.bashrc"$(date -Iseconds)".bak
		[[ -e ~/.bash_profile ]] && cp ~/.bash_profile ~/.bash_profile"$(date -Iseconds)".bak
		[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc"$(date -Iseconds)".bak
		[[ -e ~/.zprofile ]] && cp ~/.zprofile ~/.zprofile"$(date -Iseconds)".bak
		[[ -e ~/.vimrc ]] && cp ~/.vimrc ~/.vimrc"$(date -Iseconds)".bak
		[[ -e ~/.tmux.conf ]] && cp ~/.tmux.conf ~/.tmux.conf"$(date -Iseconds)".bak
	fi
fi

# My current preferred shell is elvish - https://elv.sh
mkdir -pv "$XDG_CONFIG_HOME/elvish"
mkdir -pv "$XDG_CONFIG_HOME/elvish/lib"
ln -sfv "$DF/shells/elvish/rc.elv" "$XDG_CONFIG_HOME/elvish"
ln -sfv "$DF/shells/elvish/aliases.elv" "$XDG_CONFIG_HOME/elvish/lib"
chown -R "$USER" "$XDG_CONFIG_HOME/elvish"

# Default shell on macOS
ln -sfv "$DF/shells/zsh/zshrc" "$HOME"/.zshrc
ln -sfv "$DF/shells/zsh/zprofile" "$HOME"/.zprofile
ln -sfv "$DF/shells/aliases" "$XDG_CONFIG_HOME"
chown "$USER" ~/.z*

# Default on Ubuntu
ln -sfv "$DF/shells/bash/bashrc" ~/.bashrc
ln -sfv "$DF/shells/bash/bash_profile" ~/.bash_profile
chown "$USER" ~/.bash*

# NVim setup
mkdir -pv "$XDG_CONFIG_HOME/nvim"
ln -sfv "$CONFIGS/editors/nvim/"* "$XDG_CONFIG_HOME/nvim"
[[ -f "$XDG_CONFIG_HOME/nvim/init.vim" ]] && rm -f "$XDG_CONFIG_HOME/nvim/init.vim"
chown -R "$USER" "$XDG_CONFIG_HOME/nvim"

# Basic Vim setup
ln -sfv "$CONFIGS/editors/vim/vimrc" ~/.vimrc
chown "$USER" ~/.vimrc
ln -sfv "$DF/editors/vim/.vim" ~
chown -R "$USER" ~/.vim

mkdir -pv "$HOME/.zbstudio"
ln -sfv "$CONFIGS/editors/zerobrane/user.lua" "$HOME/.zbstudio"
chown -R "$USER" "$HOME/.zbstudio"

# Ruby setup
ln -sfv "$CONFIGS/tools/rubocop.yml" ~/.rubocop.yml
chown "$USER" ~/.rubocop.yml
#mkdir -p .rbenv
#ln -sfiv "$CONFIGS/tools/default-gems" ~/.rbenv
#chown "$USER" ~/.rbenv/default-gems

# Great command prompt
if [[ $PLATFORM == 'LinuxRPi' ]]; then
	ln -sfv "$CONFIGS/tools/starshiprpi.toml" "$XDG_CONFIG_HOME/starship.toml"
else
	ln -sfv "$CONFIGS/tools/starship.toml" "$XDG_CONFIG_HOME"
fi
chown "$USER" "$XDG_CONFIG_HOME/starship.toml"

# KITTY terminal used on macOS and Linux
mkdir -pv "$XDG_CONFIG_HOME/kitty"
ln -sfv "$CONFIGS/terminals/kitty/kit"* "$XDG_CONFIG_HOME/kitty"
ln -sfv "$CONFIGS/terminals/kitty/quick-access-terminal.conf" "$XDG_CONFIG_HOME/kitty"
chown -R "$USER" "$XDG_CONFIG_HOME/kitty"

# GHOSTTY terminal used on macOS and Linux
mkdir -pv "$XDG_CONFIG_HOME/ghostty"
ln -sfv "$CONFIGS/terminals/ghostty-config" "$XDG_CONFIG_HOME/ghostty/config"
chown -R "$USER" "$XDG_CONFIG_HOME/ghostty/config"

# Alacritty Used on RPi
ln -sfv "$CONFIGS/terminals/alacritty.yml" "$XDG_CONFIG_HOME"
chown "$USER" "$XDG_CONFIG_HOME/alacritty.yml"

# tmux setup
ln -sfv "$CONFIGS/tools/tmux.conf" ~/.tmux.conf
chown "$USER" ~/.tmux.conf

# yazi
mkdir -pv "$XDG_CONFIG_HOME/yazi"
ln -sfv "$CONFIGS/tools/yazi.toml" "$XDG_CONFIG_HOME/yazi"

# carapace setup
mkdir -pv "$XDG_CONFIG_HOME/carapace/specs"
ln -sfv "$DF/completions/"* "$XDG_CONFIG_HOME/carapace/specs"
