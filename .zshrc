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
antigen bundles <<EOBUNDLES
	nyan
	ruby
	osx
	forklift
	marked2
	brew
	brew-cask
	git
	history
	command-not-found
	zsh-users/zsh-syntax-highlighting
	zsh-users/zsh-autosuggestions
EOBUNDLES
#antigen theme smt
antigen theme mashaal/wild-cherry zsh/wild-cherry.zsh-theme
antigen apply

export EDITOR='vim'
export MANPAGER='less -X' # don't clear after quitting man
DIRSTACKSIZE=12 # pushd stacksize
setopt autopushd pushdminus pushdsilent

[[ -d "/Volumes/Mac/Users/ian/" ]] && MYHD='/Volumes/Mac/Users/ian/' # old external HD
[[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/" ]] && export MATLAB_JAVA="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home" # use installed JAVA
[[ -d "/usr/local/share/zsh-completions/" ]] && fpath=(/usr/local/share/zsh-completions $fpath)
[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path) # MacTeX
[[ -d "/Applications/MATLAB_R2016b.app/bin/" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2016b.app/bin/matlab" && path=("/Applications/MATLAB_R2016b.app/bin" $path) # matlab
[[ -f "/Applications/MATLAB_R2016b.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2016b.app/bin/maci64/mlint" ~/bin/mlint # matlab
[[ -d "$HOME/anaconda3/" ]] && path=("$HOME/anaconda3/bin" $path) # anaconda scientific python

[[ -e "$DF_BASE/aliases" ]] && source "$DF_BASE/aliases"
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.rvm/bin" ]] && path=("$HOME/.rvm/bin" $path) # Add RVM to PATH for scripting
export path
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[[ -f $(which swiftenv) ]] && eval "$(swiftenv init -)"
[[ -f $(which archey) ]] && archey -c -o
[[ -f $(which ansiweather) ]] && ansiweather
