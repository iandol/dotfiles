#!/usr/bin/env zsh

cd ~ || exit

[[ ! -f ~/Downloads/nomachine.deb ]] && curl -L -o ~/Downloads/nomachine.deb https://web9001.nomachine.com/download/9.2/Linux/nomachine_9.2.18_3_amd64.deb

~/.dotfiles/bin/egetAll.sh

7z u Downloads/tools.7z /usr/local/bin/eget
7z u Downloads/tools.7z /usr/local/bin/mediamtx
7z u Downloads/tools.7z ~/.local/bin/cogmoteGO
7z u Downloads/tools.7z /usr/local/bin/rotz
7z u Downloads/tools.7z /usr/local/bin/mihomo
7z u Downloads/tools.7z /usr/local/bin/mihomosh
7z u Downloads/tools.7z ~/Downloads/nomachine.deb
7z u Downloads/tools.7z ~/Downloads/clash.deb
7z u Downloads/tools.7z /usr/local/bin/elvish

