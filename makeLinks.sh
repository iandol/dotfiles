#!/usr/bin/env bash
cd ~ || exit
printf "\n\n--->>> Make Links in %s, current directory is %s\n\n" "$SHELL" "$(pwd)"

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
CONFIGS="$DF/configs"

#few python packages
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

# My current preferred shell is elvish - https://elv.sh
mkdir -pv "$XDG_CONFIG_HOME/elvish"
mkdir -pv "$XDG_CONFIG_HOME/elvish/lib"
ln -sfiv "$DF/rc.elv" "$XDG_CONFIG_HOME/elvish"
ln -sfiv "$DF/aliases.elv" "$XDG_CONFIG_HOME/elvish/lib"
chown -R "$USER" "$XDG_CONFIG_HOME/elvish"

# Default shell on macOS
printf "Do you want to overwrite .zshrc? [y / n]:  "
read -r ans
if [[ $ans == 'y' ]]; then
	ln -sfiv "$DF/.zshrc" ~
	chown "$USER" ~/.zshrc
fi

# Default on Ubuntu
ln -sfiv "$DF/.bashrc" ~
chown "$USER" ~/.bashrc
ln -sfiv "$DF/.bash_profile" ~
chown "$USER" ~/.bash_profile

if [[ -f $(which nvim) ]]; then
	# Neovim setup
	mkdir -pv "$XDG_CONFIG_HOME/nvim"
	ln -sfiv "$CONFIGS/init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"
	[[ -f "$XDG_CONFIG_HOME/nvim/init.vim" ]] && rm -f "$XDG_CONFIG_HOME/nvim/init.vim"
	chown -R "$USER" "$XDG_CONFIG_HOME/nvim"
fi
if [[ -f $(which vim) ]]; then
	# Basic Vim setup
	ln -sfiv "$CONFIGS/.vimrc" ~
	chown "$USER" ~/.vimrc
	ln -sfiv "$DF/.vim" ~
	chown -R "$USER" ~/.vim
fi

# Ruby setup
ln -sfiv "$CONFIGS/.rubocop.yml" ~
chown "$USER" ~/.rubocop.yml
#mkdir -p .rbenv
#ln -sfiv "$CONFIGS/default-gems" ~/.rbenv
#chown "$USER" ~/.rbenv/default-gems

# Great command prompt
if [[ $PLATFORM == 'LinuxRPi' ]]; then
	ln -sfiv "$CONFIGS/starshiprpi.toml" "$XDG_CONFIG_HOME/starship.toml"
else
	ln -sfiv "$CONFIGS/starship.toml" "$XDG_CONFIG_HOME"
fi
chown "$USER" "$XDG_CONFIG_HOME/starship.toml"

# KITTY terminal used on macOS and Linux
mkdir -pv "$XDG_CONFIG_HOME/kitty"
ln -sfiv "$CONFIGS/kitty"* "$XDG_CONFIG_HOME/kitty"
ln -sfiv "$CONFIGS/quick-access-terminal.conf" "$XDG_CONFIG_HOME/kitty"
chown -R "$USER" "$XDG_CONFIG_HOME/kitty"

# GHOSTTY terminal used on macOS and Linux
mkdir -pv "$XDG_CONFIG_HOME/ghostty"
ln -sfiv "$CONFIGS/ghostty-config" "$XDG_CONFIG_HOME/ghostty/config"
chown -R "$USER" "$XDG_CONFIG_HOME/ghostty/config"

# Alacritty Used on RPi
ln -sfiv "$CONFIGS/alacritty.yml" "$XDG_CONFIG_HOME"
chown "$USER" "$XDG_CONFIG_HOME/alacritty.yml"

# tmux setup
ln -sfiv "$CONFIGS/.tmux.conf" ~
chown "$USER" ~/.tmux.conf

# yazi
mkdir -pv "$XDG_CONFIG_HOME/yazi"
ln -sfiv "$CONFIGS/yazi.toml" "$XDG_CONFIG_HOME/yazi"

# carapace setup
mkdir -pv "$XDG_CONFIG_HOME/carapace/specs"
ln -sfiv "$DF/completions/"* "$XDG_CONFIG_HOME/carapace/specs"
