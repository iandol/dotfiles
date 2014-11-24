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

export ZSHA_BASE="$HOME/.antigen"
export DF_BASE="$HOME/.dotfiles"

source "$ZSHA_BASE/antigen.zsh"
antigen use oh-my-zsh
antigen bundle nyan
antigen bundle ruby
antigen bundle osx
antigen bundle forklift
antigen bundle brew
antigen bundle git
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting

#antigen theme "$HOME/.dotfiles/steeef2.zsh-theme"
antigen theme smt
antigen apply

export PATH=~/bin:/usr/local/bin:/usr/local/sbin:~:/usr/bin:/bin:/usr/sbin:/sbin
[[ -d '/Applications/Araxis Merge.app/' ]] && export PATH=$PATH:/Applications/Araxis\ Merge.app/Contents/Utilities
[[ -d '/Volumes/Mac/Users/ian/' ]] && MYHD='/Volumes/Mac/Users/ian/'
[[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/" ]] && export MATLAB_JAVA=/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home

export EDITOR='vim'
export BZR_EDITOR='vim'
#don't clear after quitting man
export MANPAGER='less -X'
DIRSTACKSIZE=12 #pushd stacksize
setopt autopushd pushdminus pushdsilent    

[[ -e "$DF_BASE/aliases" ]] && source "$DF_BASE/aliases"
[[ -e "$DF_BASE/config" ]] && source "$DF_BASE/config"
[[ -f "$HOME/bin/ansiweather" ]] &&	ansiweather
	
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
[[ -s "$HOME/.rvm/scripts/rvm" ]] && PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting