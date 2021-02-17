#!/bin/bash
cd ~
printf "\n\n--->>> Bootstrap terminal $SHELL setup, current directory is $(pwd)\n\n"
printf '\e[36m'
[[ $(uname -a | grep -i "microsoft") ]] && MOD="WSL"
[[ $(uname -a | grep -i "armv7") ]] && MOD="RPi"
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
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		printf 'Homebrew now installed...\n'
	fi
	printf 'Added Caskroom fonts to Homebrew...\n'
	brew tap homebrew/cask-fonts
	#make sure our minimum packages are installed
	if [ -e $(which brew) ]; then
		printf 'Adding Homebrew packages...\n'
		brew install bat rbenv p7zip ruby-build zsh git figlet archey jq fzf prettyping ansiweather \
		diff-so-fancy pandoc pandoc-crossref multimarkdown libusb exodriver youtube-dl
		#cask fonts
		brew install font-symbola font-fantasque-sans-mono font-fira-code font-jetbrains-mono font-libertinus \
		font-source-code-pro font-source-sans-pro font-source-serif-pro
		printf 'Do you want to install Apps? (y / n): '
		read ans
		if [ $ans == 'y' ]; then
			#cask apps
			brew install aerial alfred bettertouchtool betterzip bitwarden bookends calibre \
			carbon-copy-cloner deckset ff-works forklift fsnotes \
			imageoptim iina kitty knockknock karabiner-elements prince \
			mpv scrivener tex-live-utility vivaldi textmate launchcontrol proxyman
			# other software
			#brew install libreoffice microsoft-word microsoft-powerpoint microsoft-excel
			#brew install dropbox #fails unless on VPN
			#brew install adoptopenjdk android-studio mono-mdk
		fi
	fi
elif [ $PLATFORM = "Linux" ]; then
	printf 'Assume we are setting up a Ubuntu machine\n'
	#make sure our minimum packages are installed
	sudo apt-get -m install build-essential gparted vim curl file zsh git mc
	sudo apt-get -m install freeglut3 gawk
	sudo apt-get -m install p7zip-full p7zip-rar figlet jq ansiweather exfat-fuse exfat-utils htop 
	sudo apt-get -m install libunrar5 libdc1394-25 libraw1394-11
	if [ ! -d /home/linuxbrew/.linuxbrew ]; then
		printf 'Installing Homebrew...\n'
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	else
		printf 'Homebrew already installed...\n'
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	fi
	if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
		printf 'Adding Homebrew packages...\n'
		brew install gcc diff-so-fancy bat rbenv ruby-build fzf prettyping 
	fi
elif [ $PLATFORM = "LinuxRPi" ]; then
	printf 'Assume we are setting up a Raspberry Pi machine\n'
	#make sure our minimum packages are installed
	sudo apt-get -m install build-essential gparted vim curl file zsh git mc
	sudo apt-get -m install freeglut3 gawk
	sudo apt-get -m install p7zip-full figlet jq ansiweather exfat-fuse exfat-utils htop 
	sudo apt-get -m install libdc1394-25 libraw1394-11
elif [ $PLATFORM = "LinuxWSL" ]; then
	printf 'Assume we are setting up a Ubuntu on Windows machine\n'
	#make sure our minimum packages are installed
	sudo apt-get install build-essential vim curl p7zip-full p7zip-rar file zsh git figlet jq ansiweather wget rbenv ruby gawk
	printf 'We will not install homebrew under WSL, try scoop in PS...'
	mkdir bin
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

ln -siv ~/.dotfiles/.zshrc ~
chown $USER ~/.zshrc
ln -siv ~/.dotfiles/.bashrc ~
chown $USER ~/.bashrc
ln -siv ~/.dotfiles/.bash_profile ~
chown $USER ~/.bash_profile
ln -siv ~/.dotfiles/.vimrc ~
chown $USER ~/.vimrc
ln -siv ~/.dotfiles/.vim ~/.vim
chown -R $USER ~/.vim
ln -siv ~/.dotfiles/.rubocop.yml ~
chown $USER ~/.rubocop.yml
ln -siv ~/.dotfiles/default-gems ~/.rbenv/
chown $USER ~/.rbenv/default-gems

printf '\e[36m'

sleep 2

printf 'Will check for a functional ZPLUG...\n'
if [ -d ~/.oh-my-zsh/ ]; then
	printf '\t...Going to replace oh-my-zsh with ZPlug... '
	rm -rf ~/.oh-my-zsh/
fi
if [ -d ~/.antigen/ ]; then
	printf '\t...Going to replace antigen with ZPlug... '
	rm -rf ~/.antigen/
fi
if [ ! -d ~/.zplug/ ]; then
	printf '\t...Going to install ZPlug... '
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
	chown -R $USER ~/.zplug
	touch ~/.zplug/packages.zsh
	printf ' DONE!'
else
	printf '\tZPlug already installed...\n'
	chown -R $USER ~/.zplug
	touch ~/.zplug/packages.zsh
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
fi 

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
	#git config --global --replace-all user.email 'iandol@machine'
	#git config --global --replace-all user.name 'iandol'
	git config --global core.editor "vim"
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
	git config --global --replace-all color.ui always
	git config --global --replace-all color.branch true
	git config --global --replace-all color.diff true
	git config --global --replace-all color.grep true
	git config --global --replace-all color.interactive true
	git config --global --replace-all color.status true
	if [ $PLATFORM = 'Darwin' ]; then
		git config --global --replace-all credential.helper osxkeychain
	else
		git config --global --replace-all credential.helper 'cache --timeout=86400'
	fi
	git config --global pager.diff "diff-so-fancy | less --tabs=4 -RFX"
	git config --global pager.show "diff-so-fancy | less --tabs=4 -RFX"
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
