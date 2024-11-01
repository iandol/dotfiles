#!/bin/bash
cd ~ || exit
printf "\n\n--->>> Bootstrap terminal %s setup, current directory is %s\n\n" "$SHELL" "$(pwd)"
printf '\e[36m'
export PLATFORM=$(uname)
export ARCH=$(uname -m)
uname -a | grep -iq "microsoft" && MOD="WSL"
uname -a | grep -iq "aarch64|armv7" && MOD="RPi"
PLATFORM=$(uname -s)$MOD
printf "Using %s...\n" "$PLATFORM"
printf '\e[0m'

[[ ! -d $HOME/.x-cmd.root ]] && eval "$(curl https://get.x-cmd.com/x7)"
x env try elvish
x pixi --install
pixi global install ruby jq fzf

[[ ! -d $HOME/.dotfiles ]] && git clone https://github.com/iandol/dotfiles.git ~/.dotfiles

elvcmds=$(cat <<EOF
use os
use path

echo "\n\n\n\n"
put "Welcome to Elvish"
x env try bat eza
bat "This is a test"
eza -l
EOF
)

elvish -c "$elvcmds"

printf '\n\n--->>> All Done...\n'
printf '\e[m'