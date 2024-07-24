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

eval "$(curl https://get.x-cmd.com)"
x env use eza fzf jq yq

printf '\n\n--->>> All Done...\n'
printf '\e[m'
