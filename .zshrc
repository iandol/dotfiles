#!/usr/bin/env zsh
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

export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)

export ZPLUG_HOME=~/.zplug
source $ZPLUG_HOME/init.zsh
zplug "zsh-users/zsh-completions", from:github
zplug "zsh-users/zsh-autosuggestions", from:github
[[ ! -x $(which fzf) ]] && zplug "zdharma/history-search-multi-word", from:github 
[[ ! -x $(which fzf) ]] && zstyle ":plugin:history-search-multi-word" clear-on-cancel "yes"
zplug "zdharma/fast-syntax-highlighting", from:github, defer:2
zplug "zsh-users/zsh-history-substring-search", from:github, defer:3
bindkey '^[[A' history-substring-search-up # binds to up-arrow ↑
bindkey '^[[B' history-substring-search-down # binds to down-arrow ↓
# Load theme file
#zplug "dracula/zsh", as:theme
#zplug "agkozak/agkozak-zsh-theme"
#zplug "mashaal/wild-cherry/zsh", from:github, use:wild-cherry.zsh-theme, as:theme
zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme
export AM_VERSIONS_PROMPT=(RUBY)
export USE_NERD_FONT=1
export ALIEN_THEME="red"
#zplug "eendroroy/alien-minimal", from:github, as:theme
#zplug "eendroroy/alien", from:github, as:theme
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	zplug install
fi
zplug load

if [[ -f $(which code) ]]; then 
	export EDITOR='code -nw'
else
	export EDITOR='vim'
fi

export MANPAGER='less -X' # don't clear after quitting man
DIRSTACKSIZE=12 # pushd stacksize
setopt autopushd pushdminus pushdsilent
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=99000
export SAVEHIST=$HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.

#[[ -d "/Volumes/Mac/Users/ian/" ]] && MYHD='/Volumes/Mac/Users/ian/' # old external HD
#[[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/" ]] && export MATLAB_JAVA="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home" # use installed JAVA
#[[ -d "/usr/local/share/zsh-completions/" ]] && fpath=(/usr/local/share/zsh-completions $fpath)
[[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]] && path=("/Applications/Araxis Merge.app/Contents/Utilities" $path)
[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path) # MacTeX
[[ -d "/Applications/MATLAB_R2018a.app/bin" ]] && path=("/Applications/MATLAB_R2018a.app/bin" $path) # matlab
[[ -d "/Applications/MATLAB_R2018a.app/bin" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2018a.app/bin/matlab" # matlab
[[ -x "/Applications/MATLAB_R2018a.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2018a.app/bin/maci64/mlint" ~/bin/mlint # matlab
if [[ -e "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
	source $HOME/miniconda3/etc/profile.d/conda.sh # miniconda, preferred way to use conda without mod path
	conda activate base
elif [[ -d "$HOME/miniconda3/" ]]; then
	path=("$HOME/miniconda3/bin" $path) 
elif [[ -d "$HOME/anaconda3/" ]]; then
	path=("$HOME/anaconda3/bin" $path) 
fi
[[ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]] && path=("/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" $path)
[[ -d "/usr/local/sbin" ]] && path=("/usr/local/sbin" $path)
[[ -d "/home/linuxbrew/.linuxbrew" ]] && path=("/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
export PATH

[[ -x $(which swiftenv) ]] && eval "$(swiftenv init -)"
[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
[[ -x $(which archey) ]] && archey -c -o
#[[ -x $(which ansiweather) ]] && ansiweather
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which fzf) ]] && source $DF/.fzf.zsh

echo "⌃a,e: ⇄ | ⌃w,k,u: 🔪 | ⌃r,s: ↑↓🔍 | d, cd - & cd #n: 🚀 | 💡 tldr ? / curl cheat.sh/?"