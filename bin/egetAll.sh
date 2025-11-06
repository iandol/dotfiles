#!/usr/bin/env zsh

eget zyedidia/eget --upgrade-only --to=/usr/local/bin
eget volllly/rotz --upgrade-only ---to=/usr/local/bin -a gnu.zip
eget bluenviron/mediamtx --to=/usr/local/bin
eget clash-verge-rev/clash-verge-rev -a amd64.deb --to=~/Downloads/clash.deb
eget --pre-release sxyazi/yazi --to=$HOME/bin --file="ya" -a gnu.zip
eget --pre-release sxyazi/yazi --to=$HOME/bin --file="yazi" -a gnu.zip 
eget MetaCubeX/mihomo --upgrade-only ---to=/usr/local/bin -a gz -a amd64-v3-v
eget SamuNatsu/mihomosh --upgrade-only ---to=/usr/local/bin -a gz

