#!/bin/bash
cd ~
printf "\n\n--->>> Bootstrap terminal setup, current directory is $(pwd)\n\n"
printf '\e[36m'

#try to install homebrew on macOS
if [[ "$(uname -s)" = "Darwin" ]]; then
	if [[ ! -e /usr/bin/clang ]]; then
		printf 'We will need to install Command-line tools ... '
		xcode-select --install
		printf 'Wait for it to finish then rerun bootstrap.sh ... '
		exit 0
	fi
	chflags nohidden ~/Library
	printf 'Let us bootstrap Homebrew if not present ... '
	if [[ -e /usr/local/bin/brew ]]; then
		printf 'Homebrew is present!\n'
	else
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		brew tap homebrew/science
		printf 'Homebrew installed...\n'
		brew tap caskroom/cask
		brew tap caskroom/fonts
		printf 'Added Caskroom to Homebrew...\n'
	fi
	#make sure our minimum packages are installed
	if [[ -e /usr/local/bin/brew ]]; then
		printf 'Adding Homebrew packages...\n'
		brew install bat rbenv ruby-build git figlet archey jq fzf prettyping ansiweather diff-so-fancy pandoc pandoc-citeproc pandoc-crossref multimarkdown libusb exodriver 
		brew cask install font-fantasquesansmono-nerd-font font-fira-code font-hack font-hasklig font-source-code-pro font-source-sans-pro imageoptim tex-live-utility 
	fi
else
	printf 'Assume we are setting up a Ubuntu machine\n'
	sudo apt-get install zsh ruby vim git figlet jq ansiweather freeglut 
	mkdir -p ~/bin
  cd ~/bin
  wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
  chmod 755 ~/bin/diff-so-fancy
fi

printf 'Let us bootstrap .dotfiles if not present ... '
if [[ -d ~/.dotfiles/.git ]]; then
	printf ' .dotfiles are present! \n'
else
	git clone https://github.com/iandol/dotfiles.git ~/.dotfiles
	chown -R $USER ~/.dotfiles
	printf 'we cloned a new .dotfiles...\n'
fi

printf 'Setting up the symbolic links at: '
date
printf '...\n'
printf '\e[32m'
[[ -e ~/.bashrc ]] && cp ~/.bashrc ~/.bashrc.bak
[[ -e ~/.bash_profile ]] && cp ~/.bash_profile ~/.bash_profile.bak
[[ -e ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc.bak

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

printf '\e[36m'

printf 'Will check for a functional Antigen...\n'
if [ -d ~/.oh-my-zsh/ ]; then
	printf '\t...Going to replace oh-my-zsh with ZPlug... '
	rm -rf ~/.oh-my-zsh/
fi
if [ -d ~/.antigen/ ]; then
	printf '\t...Going to replace antigen with ZPlug... '
	rm -rf ~/.antigen/
fi
if [ ! -d ~/.zplug/ ]; then
	printf '\t...Going to ... '
	curl -sL https://github.com/zplug/installer/raw/master/installer.zsh | zsh
else
	printf '\tAntigen already installed...\n'
	chown $USER ~/.antigen
fi

if [[ "$(uname -s)" = "Darwin" ]; then
	printf 'Linking some bin files in ~/bin/: \n'
	printf '\e[32m'
	if [ -d ~/bin/ ]; then
		ln -sv ~/.dotfiles/bin/* ~/bin
		chown -R $USER ~/bin/*
	else
		mkdir ~/bin/
		ln -sv ~/.dotfiles/bin/* ~/bin
		chown -R $USER ~/bin/*
	fi
	printf '\e[36m\n\n'

	printf 'Do you want to set up OS X defaults? (y / n):  '
	read ans
	if [ $ans == 'y' ]; then
		echo 'Enter password for setup command:'
		sudo echo -n "..."
		zsh ~/.dotfiles/macos.sh
	fi
fi

if [ -f $(which git) ]; then
	printf 'Setting some GIT defaults...\n'
	git config --global alias.last 'log -1 HEAD'
	git config --global alias.unstage 'reset HEAD --'
	git config --global alias.st status
	git config --global alias.br branch
	git config --global alias.co checkout
	git config --global alias.dt difftool
	git config --global alias.dta difftool -d
	git config --global alias.dtl difftool HEAD^
	git config --global difftool.prompt false
	git config --global color.ui always
	git config --global color.branch true
	git config --global color.diff true
	git config --global color.grep true
	git config --global color.interactive true
	git config --global color.status true
  if [ $OSTYPE == 'darwin'* ]; then
  	git config --global credential.helper osxkeychain
  fi
	git config --global pager.diff "diff-so-fancy | less --tabs=4 -RFX"
	git config --global pager.show "diff-so-fancy | less --tabs=4 -RFX"
else
	printf 'GIT is not installed, use command line tools or install homebrew...\n'
fi


printf 'Switching to use ZSH...\n'
chsh -s $(which zsh) && source ~/.zshrc
printf '\n\n--->>> All Done...\n'
printf '\e[m'
