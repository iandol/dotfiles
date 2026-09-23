#!/usr/bin/env bash
#
# bootstrap.sh - provision a new machine (macOS, Ubuntu, Raspberry Pi OS or WSL).
#
# Core toolchain: x-cmd, pixi and Homebrew (macOS/Ubuntu only). Dotfiles are
# linked with rotz; zsh uses znap (zsh-snap) as its plugin manager.
#
# Usage: bash bootstrap.sh

set -o nounset -o pipefail

readonly DOTFILES_REPO="https://codeberg.org/iandol/dotfiles.git"
readonly DOTFILES_DIR="${HOME}/.dotfiles"
readonly ZNAP_DIR="${HOME}/.local/share/znap"
readonly ZNAP_REPO="https://github.com/marlonrichert/zsh-snap.git"
readonly ROTZ_REPO="volllly/rotz"
readonly ROTZ_INSTALLER="https://volllly.github.io/rotz/install.sh"
readonly XCMD_INSTALLER="https://get.x-cmd.com/x7"
readonly PIXI_INSTALLER="https://pixi.sh/install.sh"
readonly HOMEBREW_INSTALLER="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
readonly LINUXBREW_PREFIX="/home/linuxbrew/.linuxbrew"
readonly DIFF_SO_FANCY_FATPACK="https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy"

PLATFORM=""
ROTZ_BIN=""

if [[ -t 1 && -n "${TERM:-}" ]]; then
	readonly C_RESET=$'\e[0m' C_CYAN=$'\e[36m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m' C_RED=$'\e[31m'
else
	readonly C_RESET="" C_CYAN="" C_GREEN="" C_YELLOW="" C_RED=""
fi

info() { printf '%s%s%s\n' "${C_CYAN}" "$*" "${C_RESET}"; }
ok() { printf '%s%s%s\n' "${C_GREEN}" "$*" "${C_RESET}"; }
warn() { printf '%s%s%s\n' "${C_YELLOW}" "$*" "${C_RESET}" >&2; }

die() {
	printf '%s%s%s\n' "${C_RED}" "$*" "${C_RESET}" >&2
	exit 1
}

step() { printf '\n%s==> %s%s\n' "${C_CYAN}" "$*" "${C_RESET}"; }

have() { command -v "$1" >/dev/null 2>&1; }

confirm() {
	local reply
	[[ -t 0 ]] || return 1
	read -r -p "$1 [y/N] " reply
	[[ "${reply:-}" == [Yy]* ]]
}

detect_platform() {
	local kernel arch
	kernel="$(uname -s)"
	arch="$(uname -m)"
	case "${kernel}" in
	Darwin)
		PLATFORM="macos"
		;;
	Linux)
		if grep -qi microsoft /proc/version 2>/dev/null; then
			PLATFORM="wsl"
		elif grep -qi raspberry /proc/device-tree/model 2>/dev/null; then
			PLATFORM="rpi"
		elif [[ "${arch}" == aarch64 || "${arch}" == armv7l || "${arch}" == armv6l ]]; then
			PLATFORM="rpi"
		else
			PLATFORM="ubuntu"
		fi
		;;
	*)
		PLATFORM="unknown"
		;;
	esac
}

install_xcmd() {
	local xbin="${HOME}/.x-cmd.root/bin/x"
	if [[ -x "${xbin}" ]]; then
		ok "x-cmd already installed"
		return 0
	fi

	step "Installing x-cmd"
	if have curl; then
		bash -c 'eval "$(curl -fsSL "$1")"' _ "${XCMD_INSTALLER}" || die "x-cmd installation failed"
	elif have wget; then
		bash -c 'eval "$(wget -qO- "$1")"' _ "${XCMD_INSTALLER}" || die "x-cmd installation failed"
	else
		die "curl or wget is required to install x-cmd"
	fi
	[[ -x "${xbin}" ]] && ok "x-cmd installed"
}

ensure_pixi() {
	if ! have pixi && [[ -x "${HOME}/.pixi/bin/pixi" ]]; then
		export PATH="${HOME}/.pixi/bin:${PATH}"
	fi
	if have pixi; then
		ok "pixi ready"
		return 0
	fi

	step "Installing pixi"
	curl -fsSL "${PIXI_INSTALLER}" | bash || warn "pixi installation failed"
	if [[ -x "${HOME}/.pixi/bin/pixi" ]]; then
		export PATH="${HOME}/.pixi/bin:${PATH}"
	fi
}

install_rotz() {
	ROTZ_BIN=""
	if have rotz; then
		ROTZ_BIN="$(command -v rotz)"
	elif [[ -x "${HOME}/.local/bin/rotz" ]]; then
		ROTZ_BIN="${HOME}/.local/bin/rotz"
	fi
	if [[ -n "${ROTZ_BIN}" ]]; then
		ok "rotz already installed (${ROTZ_BIN})"
		return 0
	fi

	step "Installing rotz"
	if [[ -x "${HOME}/.x-cmd.root/bin/x" ]]; then
		bash -c '. "$HOME/.x-cmd.root/X" >/dev/null 2>&1; x eget use "$1"' _ "${ROTZ_REPO}" ||
			warn "x eget could not install rotz"
	fi
	if [[ ! -x "${HOME}/.local/bin/rotz" ]] && have curl; then
		ROTZ_INSTALL="${HOME}/.local" sh -c "$(curl -fsSL "${ROTZ_INSTALLER}")" || warn "rotz installer failed"
	fi
	if [[ -x "${HOME}/.local/bin/rotz" ]]; then
		ROTZ_BIN="${HOME}/.local/bin/rotz"
		ok "rotz installed (${ROTZ_BIN})"
	fi
}

setup_dotfiles() {
	if [[ -d "${DOTFILES_DIR}/.git" ]]; then
		step "Updating dotfiles"
		git -C "${DOTFILES_DIR}" pull --ff-only || warn "Could not update ${DOTFILES_DIR}"
	else
		step "Cloning dotfiles"
		git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}" || die "Could not clone ${DOTFILES_REPO}"
	fi

	install_rotz

	if [[ -z "${ROTZ_BIN}" ]]; then
		warn "rotz is unavailable; link dotfiles later with: rotz -d ${DOTFILES_DIR} link --force"
		return 0
	fi
	step "Linking dotfiles with rotz"
	"${ROTZ_BIN}" -d "${DOTFILES_DIR}" link --force ||
		warn "rotz reported errors; rerun: rotz -d ${DOTFILES_DIR} link --force"
}

setup_zsh() {
	local legacy_dirs=(
		"${HOME}/.oh-my-zsh"
		"${HOME}/.antigen"
		"${HOME}/.zplug"
		"${HOME}/.zi"
		"${HOME}/.zinit"
		"${HOME}/.local/share/zinit"
	)
	local dir
	for dir in "${legacy_dirs[@]}"; do
		if [[ -e "${dir}" ]]; then
			warn "Removing legacy zsh plugin manager ${dir}"
			rm -rf "${dir}"
		fi
	done

	if [[ -d "${ZNAP_DIR}/.git" ]]; then
		ok "znap already installed"
	else
		step "Installing znap (zsh-snap)"
		mkdir -p "$(dirname "${ZNAP_DIR}")"
		git clone --depth 1 "${ZNAP_REPO}" "${ZNAP_DIR}" || warn "znap installation failed"
	fi

	local zsh_bin=""
	if [[ "${PLATFORM}" == "macos" ]] && have brew && [[ -x "$(brew --prefix)/bin/zsh" ]]; then
		zsh_bin="$(brew --prefix)/bin/zsh"
	else
		zsh_bin="$(command -v zsh || true)"
	fi
	if [[ -z "${zsh_bin}" ]]; then
		warn "zsh is not installed; skipping default shell change"
		return 0
	fi
	if [[ "${SHELL:-}" == "${zsh_bin}" ]]; then
		ok "zsh is already the default shell"
		return 0
	fi

	if ! grep -qxF "${zsh_bin}" /etc/shells 2>/dev/null; then
		printf '%s\n' "${zsh_bin}" | sudo tee -a /etc/shells >/dev/null
	fi
	if chsh -s "${zsh_bin}"; then
		ok "Default shell set to ${zsh_bin} (restart your terminal)"
	else
		warn "Could not change the default shell; run: chsh -s ${zsh_bin}"
	fi
}

setup_rbenv() {
	have rbenv || return 0
	local rbenv_root plugin gems
	rbenv_root="$(rbenv root)"
	plugin="${rbenv_root}/plugins/rbenv-default-gems"
	gems="${DOTFILES_DIR}/package-managers/default-gems"
	[[ -f "${gems}" ]] || return 0
	if [[ ! -d "${plugin}/.git" ]]; then
		step "Installing rbenv-default-gems"
		git clone --depth 1 https://github.com/rbenv/rbenv-default-gems.git "${plugin}" ||
			warn "Could not install rbenv-default-gems"
	fi
	[[ -d "${plugin}/.git" ]] && ln -sfn "${gems}" "${rbenv_root}/default-gems"
}

setup_git() {
	if ! have git; then
		warn "git is not installed; skipping git configuration"
		return 0
	fi

	step "Configuring git defaults"
	git config --global --replace-all user.email "iandol@machine"
	git config --global --replace-all user.name "iandol"
	have nvim && git config --global --replace-all core.editor "nvim"
	git config --global --replace-all init.defaultBranch main
	git config --global --replace-all core.autocrlf input
	git config --global --replace-all core.eol lf
	git config --global --replace-all pull.ff only
	git config --global --replace-all alias.last 'log -1 HEAD'
	git config --global --replace-all alias.unstage 'reset HEAD --'
	git config --global --replace-all alias.history 'log -p --'
	git config --global --replace-all alias.st 'status'
	git config --global --replace-all alias.br 'branch'
	git config --global --replace-all alias.bl 'branch -v -a'
	git config --global --replace-all alias.co 'checkout'
	git config --global --replace-all alias.dt 'difftool'
	git config --global --replace-all alias.dta 'difftool -d'
	git config --global --replace-all alias.dtl 'difftool HEAD^'
	git config --global --replace-all difftool.prompt false
	if [[ "${PLATFORM}" == "macos" ]]; then
		git config --global --replace-all credential.helper osxkeychain
	else
		git config --global --replace-all credential.helper 'cache --timeout=86400'
	fi
	if have delta; then
		git config --global core.pager "delta --line-numbers"
		git config --global interactive.diffFilter "delta --color-only --features=interactive"
		git config --global delta.features "decorations"
		git config --global delta.navigate "true"
	elif have diff-so-fancy; then
		git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
		git config --global interactive.diffFilter "diff-so-fancy --patch"
	fi
	git config --global color.ui true
	git config --global color.diff-highlight.oldNormal "red bold"
	git config --global color.diff-highlight.oldHighlight "red bold 52"
	git config --global color.diff-highlight.newNormal "green bold"
	git config --global color.diff-highlight.newHighlight "green bold 22"
	git config --global color.diff.meta "11"
	git config --global color.diff.frag "magenta bold"
	git config --global color.diff.func "146 bold"
	git config --global color.diff.commit "yellow bold"
	git config --global color.diff.old "red bold"
	git config --global color.diff.new "green bold"
	git config --global color.diff.whitespace "red reverse"
}

apt_install() {
	if ! have apt-get; then
		warn "apt-get is unavailable; skipping: $*"
		return 0
	fi
	sudo apt-get install -y --ignore-missing "$@" || warn "Some apt packages could not be installed"
}

snap_install() {
	if ! have snap; then
		warn "snap is unavailable; skipping: $*"
		return 0
	fi
	local package
	for package in "$@"; do
		if snap list "${package}" >/dev/null 2>&1; then
			ok "snap ${package} already installed"
		else
			sudo snap install "${package}" || warn "Could not install snap ${package}"
		fi
	done
}

install_homebrew() {
	if have brew; then
		ok "Homebrew already installed"
		return 0
	fi

	local prefixes prefix
	if [[ "${PLATFORM}" == "macos" ]]; then
		prefixes=(/opt/homebrew /usr/local)
	else
		prefixes=("${LINUXBREW_PREFIX}")
	fi
	for prefix in "${prefixes[@]}"; do
		if [[ -x "${prefix}/bin/brew" ]]; then
			eval "$("${prefix}/bin/brew" shellenv)"
			ok "Homebrew already installed"
			return 0
		fi
	done

	step "Installing Homebrew"
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "${HOMEBREW_INSTALLER}")" || warn "Homebrew installation failed"
	for prefix in "${prefixes[@]}"; do
		if [[ -x "${prefix}/bin/brew" ]]; then
			eval "$("${prefix}/bin/brew" shellenv)"
			return 0
		fi
	done
	warn "Homebrew is still unavailable"
}

brew_install() {
	if ! have brew; then
		warn "Homebrew is unavailable; skipping: $*"
		return 0
	fi
	brew install "$@"
}

brew_install_cask() {
	if ! have brew; then
		warn "Homebrew is unavailable; skipping casks: $*"
		return 0
	fi
	brew install --cask "$@"
}

link_brew_fonts() {
	local font_dir files
	font_dir="$(brew --prefix)/share/fonts"
	[[ -d "${font_dir}" ]] || return 0
	shopt -s nullglob
	files=("${font_dir}"/*)
	shopt -u nullglob
	((${#files[@]})) || return 0
	sudo mkdir -p /usr/local/share/fonts
	sudo ln -v -f -L "${files[@]}" /usr/local/share/fonts/
	sudo fc-cache -f >/dev/null
}

install_diff_so_fancy_fatpack() {
	[[ -x "${HOME}/bin/diff-so-fancy" ]] && return 0
	have curl || return 0
	step "Installing diff-so-fancy"
	mkdir -p "${HOME}/bin"
	if curl -fsSL "${DIFF_SO_FANCY_FATPACK}" -o "${HOME}/bin/diff-so-fancy"; then
		chmod +x "${HOME}/bin/diff-so-fancy"
	else
		warn "Could not install diff-so-fancy"
	fi
}

setup_macos() {
	if ! xcode-select -p >/dev/null 2>&1; then
		step "Xcode Command Line Tools are required"
		xcode-select --install || true
		die "Rerun bootstrap.sh after the Command Line Tools installation finishes."
	fi
	chflags nohidden "${HOME}/Library" 2>/dev/null || true

	install_homebrew
	if ! have brew; then
		warn "Homebrew is unavailable; skipping macOS packages"
		return 0
	fi

	step "Installing Homebrew formulae"
	local formulae=(
		git bat p7zip pixi fzf ruby-build zsh
		neovim figlet prettyping ansiweather media-info
		git-delta diff-so-fancy pandoc pandoc-crossref
		multimarkdown libusb exodriver yt-dlp
	)
	brew_install "${formulae[@]}"

	brew tap rsteube/tap
	brew_install carapace
	brew tap v2raya/v2raya
	brew_install v2raya
	brew_install clash-verge-rev

	step "Installing fonts"
	local fonts=(
		font-symbols-only-nerd-font font-recursive-code font-fantasque-sans-mono
		font-fira-code font-jetbrains-mono font-cascadia-code font-libertinus
		font-stix font-alegreya font-alegreya-sans
	)
	brew_install_cask "${fonts[@]}"
	brew tap iandol/adobe-fonts
	brew_install font-source-sans font-source-serif

	if confirm "Install GUI applications (casks)?"; then
		local apps=(
			alfred blackhole-2ch bettertouchtool betterzip bitwarden
			bookends calibre daisydisk deckset draw-things ff-works forklift
			fsnotes hex-fiend iina imageoptim inkscape kitty knockknock
			launchcontrol mpv nomachine prince proxyman r scrivener
			suspicious-package syntax-highlight xld wechat visual-studio-code
			zerotier-one
		)
		local app
		for app in "${apps[@]}"; do
			brew install --cask "${app}" || warn "Could not install ${app}"
		done
	fi
}

setup_ubuntu() {
	step "Installing Ubuntu packages"
	sudo apt-get update || warn "apt-get update failed"
	apt_install \
		apt-transport-https ca-certificates software-properties-common \
		build-essential zsh git gparted vim curl file mc wget \
		freeglut3 gawk mesa-utils exfatprogs \
		p7zip-full p7zip-rar figlet jq ansiweather htop \
		libunrar5 libdc1394-25 libraw1394-11 \
		gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
		synaptic zathura zathura-pdf-poppler zathura-ps \
		rofi i3 xdotool unicode gucharmap feh \
		network-manager-applet blueman \
		python3-pip python3-venv \
		openssh-server wakeonlan etherwake kitty-terminfo

	install_homebrew
	if have brew; then
		step "Installing Homebrew packages"
		local formulae=(
			gcc git-delta diff-so-fancy bat rbenv ruby-build fzf pixi
			procs ripgrep prettyping starship httping
		)
		brew_install "${formulae[@]}"
		brew tap rsteube/tap
		brew_install carapace

		local fonts=(
			font-symbols-only-nerd-font font-recursive-code font-fantasque-sans-mono
			font-fira-code font-jetbrains-mono font-cascadia-code font-libertinus
			font-alegreya font-alegreya-sans font-stix
		)
		brew_install_cask "${fonts[@]}"
		link_brew_fonts
	fi

	snap_install code arduino rpi-imager obs-studio
}

setup_rpi() {
	step "Installing Raspberry Pi packages"
	sudo apt-get update || warn "apt-get update failed"
	apt_install \
		build-essential gparted vim curl file zsh git mc wget \
		gawk mesa-utils exfatprogs freeglut3-dev libglut-dev \
		pipewire-pulse pulseaudio-utils openssh-server \
		i3 rofi nitrogen xdotool \
		p7zip-full p7zip-rar figlet jq ansiweather exfat-fuse exfat-utils htop \
		libunrar5 libdc1394-25 libraw1394-11 \
		snapd synaptic zathura zathura-pdf-poppler zathura-ps flatpak \
		wakeonlan etherwake python3-pip python3-venv kitty-terminfo

	snap_install core
	if have snap && ! snap list starship >/dev/null 2>&1; then
		sudo snap install starship --edge || warn "Could not install snap starship"
	fi
	have vlc || sudo snap install vlc || warn "Could not install snap vlc"
	have code || sudo snap install --classic code || warn "Could not install snap code"

	if have flatpak; then
		flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo ||
			warn "Could not add the flathub remote"
		flatpak install -y flathub com.obsproject.Studio || warn "Could not install OBS via flatpak"
	fi

	install_diff_so_fancy_fatpack
}

setup_wsl() {
	step "Installing WSL packages"
	sudo apt-get update || warn "apt-get update failed"
	apt_install \
		build-essential vim curl p7zip-full p7zip-rar file zsh git \
		figlet jq ansiweather wget rbenv ruby gawk
	info "Skipping Homebrew under WSL; use scoop/winget for Windows applications."
	install_diff_so_fancy_fatpack
}

main() {
	cd "${HOME}" || die "Cannot change to ${HOME}"
	detect_platform
	printf '\n--->>> Bootstrap on %s (%s)\n' "$(uname -srm)" "${PLATFORM}"

	case "${PLATFORM}" in
	macos) setup_macos ;;
	ubuntu) setup_ubuntu ;;
	rpi) setup_rpi ;;
	wsl) setup_wsl ;;
	*) die "Unsupported platform: $(uname -s) $(uname -m)" ;;
	esac

	install_xcmd
	ensure_pixi
	setup_dotfiles
	setup_zsh
	setup_rbenv
	setup_git

	printf '\n--->>> All done. Restart your terminal (or log out) to use zsh with znap.\n'
}

main "$@"
