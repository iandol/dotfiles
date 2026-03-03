#!/usr/bin/env zsh

FORCE_REFRESH=0
YAZI_ONLY=0

while getopts ":fy" opt; do
	case "${opt}" in
		f) FORCE_REFRESH=1 ;;
		y) YAZI_ONLY=1; FORCE_REFRESH=1 ;;
		*) echo "Usage: $(basename "$0") [-f] [-y]" >&2; exit 2 ;;
	esac
done
shift $((OPTIND - 1))

OS=$(uname -s)
UPGRADE_FLAG=(--upgrade-only)
(( FORCE_REFRESH )) && UPGRADE_FLAG=()

if (( ! YAZI_ONLY )); then
	[[ ! -x /usr/local/bin/eget ]] && curl https://zyedidia.github.io/eget.sh | sh && mv eget /usr/local/bin

	eget zyedidia/eget "${UPGRADE_FLAG[@]}" --to=/usr/local/bin
	eget bluenviron/mediamtx "${UPGRADE_FLAG[@]}" --to=/usr/local/bin

	[[ $OS = "Linux" ]] && eget volllly/rotz "${UPGRADE_FLAG[@]}" --to=/usr/local/bin -a gnu.zip
	[[ $OS = "Darwin" ]] && eget volllly/rotz "${UPGRADE_FLAG[@]}" --to=/usr/local/bin -a darwin.zip
fi

[[ $OS = "Linux" ]] && eget --pre-release sxyazi/yazi --to=$HOME/bin --file="yazi" -a gnu.zip \
	&& eget --pre-release "${UPGRADE_FLAG[@]}" sxyazi/yazi --to=$HOME/bin --file="ya" -a gnu.zip 
[[ $OS = "Darwin" ]] && eget --pre-release sxyazi/yazi --to=$HOME/bin --file="yazi" \
	&& eget --pre-release "${UPGRADE_FLAG[@]}" sxyazi/yazi --to=$HOME/bin --file="ya"

if (( ! YAZI_ONLY )); then
	[[ $OS = "Linux" ]] && eget MetaCubeX/mihomo "${UPGRADE_FLAG[@]}" ---to=/usr/local/bin -a gz -a amd64-v3-v
	[[ $OS = "Darwin" ]] && eget MetaCubeX/mihomo "${UPGRADE_FLAG[@]}" ---to=/usr/local/bin -a arm64-v

	eget SamuNatsu/mihomosh "${UPGRADE_FLAG[@]}" ---to=/usr/local/bin -a gz

	[[ $OS = "Linux" ]] && eget --pre-release clash-verge-rev/clash-verge-rev "${UPGRADE_FLAG[@]}" -a "amd64.deb" -a "^sig" --to=~/Downloads/clash.deb
	[[ $OS = "Darwin" ]] && eget --pre-release clash-verge-rev/clash-verge-rev "${UPGRADE_FLAG[@]}" -a "aarch64.dmg" -a "^sig" --to=~/Downloads/clash.dmg
fi

