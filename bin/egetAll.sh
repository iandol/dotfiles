#!/usr/bin/env zsh
OS=$(uname -s)

eget zyedidia/eget --upgrade-only --to=/usr/local/bin

[[ $OS = "Linux" ]] && eget volllly/rotz --upgrade-only ---to=/usr/local/bin -a gnu.zip
[[ $OS = "Darwin" ]] && eget volllly/rotz --upgrade-only ---to=/usr/local/bin -a darwin.zip

eget bluenviron/mediamtx --upgrade-only --to=/usr/local/bin

[[ $OS = "Linux" ]] && eget clash-verge-rev/clash-verge-rev -a amd64.deb --to=~/Downloads/clash.deb
[[ $OS = "Darwin" ]] && eget clash-verge-rev/clash-verge-rev -a aarch64.dmg --to=~/Downloads/clash.dmg

[[ $OS = "Linux" ]] && eget --pre-release sxyazi/yazi --to=$HOME/bin --file="ya" -a gnu.zip \
	&& eget --pre-release sxyazi/yazi --to=$HOME/bin --file="yazi" -a gnu.zip 
[[ $OS = "Darwin" ]] && eget --pre-release sxyazi/yazi --to=$HOME/bin --file="ya" \
	&& eget --pre-release sxyazi/yazi --to=$HOME/bin --file="yazi"

[[ $OS = "Linux" ]] && eget MetaCubeX/mihomo --upgrade-only ---to=/usr/local/bin -a gz -a amd64-v3-v
[[ $OS = "Darwin" ]] && eget MetaCubeX/mihomo --upgrade-only ---to=/usr/local/bin -a arm64-v
 
eget SamuNatsu/mihomosh --upgrade-only ---to=/usr/local/bin -a gz

