# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="steeef2"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(osx ruby brew git nyan)

source $ZSH/oh-my-zsh.sh

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable hg git bzr svn

# Customize to your needs...
#echo $PATH
if [ -d '/Volumes/Mac/Users/ian/' ]; then
	MYHD='/Volumes/Mac/Users/ian/'
fi
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:~:/usr/bin:/bin:/usr/sbin:/sbin

export EDITOR='vim'
export BZR_EDITOR='vim'
#don't clear after quitting man
export MANPAGER='less -X'
DIRSTACKSIZE=12 #pushd stacksize
setopt autopushd pushdminus pushdsilent

source ~/.dotfiles/aliases
source ~/.dotfiles/config

figlet "Hello Dave..."

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
