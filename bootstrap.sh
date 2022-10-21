#!/bin/bash
cd ~
printf "\n\n--->>> Bootstrap terminal $SHELL setup, current directory is $(pwd)\n\n"
printf '\e[36m'
[[ $(uname -a | grep -i "microsoft") ]] && MOD="WSL"
[[ $(uname -a | grep -Ei "aaarch64|armv7") ]] && MOD="RPi"
export PLATFORM=$(uname -s)$MOD
printf "Using $PLATFORM...\n"

#try to install homebrew on macOS
if [ $PLATFORM = "Darwin" ]; then
	if [ ! -e /usr/bin/clang ]; then
		printf 'We will need to install Command-line tools ... '
		xcode-select --install
		printf 'Wait for it to finish then rerun bootstrap.sh ... '
		exit 0
	fi
	chflags nohidden ~/Library
	printf 'Let us bootstrap Homebrew if not present ... '
	if [ -e $(which brew) ]; then
		printf 'Homebrew is present!\n'
	else
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		printf 'Homebrew now installed...\n'
	fi
	printf 'Added Caskroom fonts to Homebrew...\n'
	brew tap homebrew/cask-fonts
	#make sure our minimum packages are installed
	if [ -e $(which brew) ]; then
		printf 'Adding Homebrew packages...\n'
		brew install bat p7zip ruby-build rbenv pyenv zsh neovim git figlet archey jq \
		fzf prettyping ansiweather media-info starship tmux \
		diff-so-fancy mosh pandoc pandoc-crossref multimarkdown libusb exodriver youtube-dl
		#cask fonts
		brew install font-fantasque-sans-mono font-fira-code font-jetbrains-mono font-cascadia-code font-libertinus \
		font-source-code-pro font-source-sans-pro font-source-serif-pro \
		font-cascadia-code font-libertinus
		printf 'Do you want to install Apps? (y / n): '
		read ans
		if [ $ans == 'y' ]; then
			#cask apps
			brew install aerial alfred basictex bettertouchtool betterzip bitwarden \
			bookends calibre \
			carbon-copy-cloner deckset ff-works forklift fsnotes gswitch hex-fiend \
			iina imageoptim kitty knockknock launchcontrol karabiner-elements mpv \
			prince proxyman scrivener suspicious-package tex-live-utility vivaldi textmate \
			zerotier-one
			# other software
			#brew install libreoffice microsoft-word microsoft-powerpoint microsoft-excel
			#brew install dropbox #fails unless on VPN
			#brew install adoptopenjdk android-studio mono-mdk
		fi
	fi
elif [ $PLATFORM = "Linux" ]; then
	printf 'Assume we are setting up a Ubuntu machine\n'
	#make sure our minimum packages are installed
	sudo apt -my install build-essential zsh git gparted neovim curl file mc
	sudo apt -my install freeglut3 gawk
	sudo apt -my install p7zip-full p7zip-rar figlet jq ansiweather exfat-fuse exfat-utils htop 
	sudo apt -my install libunrar5 libdc1394-25 libraw1394-11
	
	if [ ! -d /home/linuxbrew/.linuxbrew ]; then
		printf 'Installing Homebrew...\n'
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	else
		printf 'Homebrew already installed...\n'
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	fi
	if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
		printf 'Adding Homebrew packages...\n'
		brew install gcc diff-so-fancy bat rbenv ruby-build fzf prettyping
		brew tap linuxbrew/fonts
		brew install font-fantasque-sans-mono font-fira-code \
		font-jetbrains-mono font-cascadia-code font-libertinus 
		brew install --HEAD font-source-sans-3
		sudo ln -s /home/linuxbrew/.linuxbrew/share/fonts /usr/local/share/fonts/
		sudo fc-cache -fv
	fi
elif [ $PLATFORM = "LinuxRPi" ]; then
	printf 'Assume we are setting up a Raspberry Pi machine\n'
	#make sure our minimum packages are installed
	sudo apt update
	sudo apt -my install build-essential gparted vim curl file zsh git mc
	sudo apt -my install freeglut3 gawk
	sudo apt -my install p7zip-full figlet jq ansiweather exfat-fuse exfat-utils htop 
	sudo apt -my install libdc1394-25 libraw1394-11
	sudo apt -my install code snapd synaptic
	sudo snap install core
	sudo snap install starship --edge
	mkdir -p bin
	curl https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy > bin/diff-so-fancy
	chmod +x bin/diff-so-fancy
elif [ $PLATFORM = "LinuxWSL" ]; then
	printf 'Assume we are setting up a Ubuntu on Windows machine\n'
	#make sure our minimum packages are installed
	sudo apt-get install build-essential vim curl p7zip-full p7zip-rar file zsh git figlet jq ansiweather wget rbenv ruby gawk
	printf 'We will not install homebrew under WSL, try scoop in PS...'
	mkdir -p bin
	curl https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy > bin/diff-so-fancy
	chmod +x bin/diff-so-fancy
fi

sleep 1

if [ -d "~/.rbenv/" ]; then
	git clone https://github.com/rbenv/rbenv-default-gems.git $(rbenv root)/plugins/rbenv-default-gems
	ln -s $HOME/.dotfiles/default-gems $HOME/.rbenv/
fi

#few python packages
printf "Do you want to add Python packages? [y / n]:  "
read ans
if [ $ans == 'y' ]; then
	printf 'Install a few python packages ... '
	pip3 install howdoi black pylint
fi

sleep 2

printf 'Let us bootstrap .dotfiles if not present ... '
read -p "Press any key to continue... " -n1 -s; printf '\n'
if [ -d ~/.dotfiles/.git ]; then
	printf ' .dotfiles are present! \n'
else
	git clone https://github.com/iandol/dotfiles.git ~/.dotfiles
	chown -R $USER ~/.dotfiles
	printf 'We cloned a new .dotfiles...\n'
fi

sleep 2

printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
[ -e ~/.bashrc ] && cp ~/.bashrc ~/.bashrc`date -Iseconds`.bak
[ -e ~/.bash_profile ] && cp ~/.bash_profile ~/.bash_profile`date -Iseconds`.bak
[ -e ~/.zshrc ] && cp ~/.zshrc ~/.zshrc`date -Iseconds`.bak

.dotfiles/makeLinks.sh

printf '\e[36m'

sleep 2

printf 'Will check for a functional ZInit...\n'
if [ -d ~/.oh-my-zsh/ ]; then
	printf '\t...Going to replace oh-my-zsh with ZInit... '
	rm -rf ~/.oh-my-zsh/
fi
if [ -d ~/.antigen/ ]; then
	printf '\t...Going to replace antigen with ZInit... '
	rm -rf ~/.antigen/
fi
if [ -d ~/.zplug/ ]; then
	printf '\t...Going to replace antigen with ZInit... '
	rm -rf ~/.antigen/
fi
if [ ! -d ~/.zi/ ]; then
	printf '\t...Going to install ZPlug... '
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
	chown -R $USER ~/.zi
	printf ' DONE!'
else
	printf '\tZInit already installed...\n'
	chown -R $USER ~/.zi
fi

printf 'Linking some bin files in ~/bin/: \n'
printf '\e[32m'
mkdir -pv ~/bin/
if [ $PLATFORM = "Darwin" ]; then
	ln -sv ~/.dotfiles/bin/* $HOME/bin
else
	ln -sv ~/.dotfiles/bin/*.sh $HOME/bin
	ln -sv ~/.dotfiles/bin/*.rb $HOME/bin
fi
chown -R $USER ~/bin/*
printf '\e[36m\n\n'

if [ $PLATFORM = "Darwin" ]; then
	printf "Do you want to set up OS X defaults? [y / n]:  "
	read ans
	if [ $ans == 'y' ]; then
		echo 'Enter password for setup command:'
		sudo echo -n "..."
		zsh ~/.dotfiles/macos.sh
	fi
fi

sleep 2

if [ -f $(which git) ]; then
	printf 'Setting some GIT defaults...\n'
	git config --global --replace-all user.email 'iandol@machine'
	git config --global --replace-all user.name 'iandol'
	[[ -f $(which nvim) ]] && git config --global core.editor "nvim"
	git config --global init.defaultBranch main
	git config --global core.autocrlf input
	git config --global core.eol lf
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
	if [ $PLATFORM = 'Darwin' ]; then
		git config --global --replace-all credential.helper osxkeychain
	else
		git config --global --replace-all credential.helper 'cache --timeout=86400'
	fi
	git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
	git config --global interactive.diffFilter "diff-so-fancy --patch"
	git config --global color.ui true
	git config --global color.diff-highlight.oldNormal    "red bold"
	git config --global color.diff-highlight.oldHighlight "red bold 52"
	git config --global color.diff-highlight.newNormal    "green bold"
	git config --global color.diff-highlight.newHighlight "green bold 22"
	git config --global color.diff.meta       "11"
	git config --global color.diff.frag       "magenta bold"
	git config --global color.diff.func       "146 bold"
	git config --global color.diff.commit     "yellow bold"
	git config --global color.diff.old        "red bold"
	git config --global color.diff.new        "green bold"
	git config --global color.diff.whitespace "red reverse"
else
	printf 'GIT is not installed, use command line tools or install brew/apt...\n'
fi

sleep 2

if [ -x `which zsh` ]; then
	printf 'Switching to use ZSH...\n'
	if [ $PLATFORM = "Darwin" ]; then
		chsh -s /usr/local/bin/zsh && source ~/.zshrc #installed via brew
	else
		chsh -s $(which zsh) && source ~/.zshrc
	fi
fi
printf '\n\n--->>> All Done...\n'
printf '\e[m'
