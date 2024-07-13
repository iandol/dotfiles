#!/bin/bash
cd ~
printf "\n\n--->>> Bootstrap terminal $SHELL setup, current directory is $(pwd)\n\n"
printf '\e[36m'
export PLATFORM=$(uname)
export ARCH=$(uname -m)
[[ $(uname -a | grep -i "microsoft") ]] && MOD="WSL"
[[ $(uname -a | grep -Ei "aarch64|armv7") ]] && MOD="RPi"
export PLATFORM=$(uname -s)$MOD
printf "Using $PLATFORM...\n"

printf '\e[0m'
curl https://get.x-cmd.com | sh -i
x env use 