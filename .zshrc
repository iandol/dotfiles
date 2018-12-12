#!/usr/bin/env zsh

export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)

#--------------------------ZPLUG SETUP
export ZPLUG_HOME=~/.zplug
source $ZPLUG_HOME/init.zsh
zplug "zsh-users/zsh-completions", from:github
zplug "zsh-users/zsh-autosuggestions", from:github
#-----if fzf is not installed
[[ ! -x $(which fzf) ]] && zplug "zdharma/history-search-multi-word", from:github 
[[ ! -x $(which fzf) ]] && zstyle ":plugin:history-search-multi-word" clear-on-cancel "yes"
#-----Load theme file
#zplug "dracula/zsh", as:theme #zplug "agkozak/agkozak-zsh-theme" #zplug "mashaal/wild-cherry/zsh", from:github, use:wild-cherry.zsh-theme, as:theme #zplug "eendroroy/alien-minimal", from:github, as:theme #zplug "eendroroy/alien", from:github, as:theme
zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme
#export AM_VERSIONS_PROMPT=(RUBY)
#export USE_NERD_FONT=1
#export ALIEN_THEME="red"
#-----supposed to come after compinit
zplug "zdharma/fast-syntax-highlighting", from:github, defer:2
zplug "zsh-users/zsh-history-substring-search", from:github, defer:2
bindkey '^[[A' history-substring-search-up # binds to up-arrow ↑
bindkey '^[[B' history-substring-search-down # binds to down-arrow ↓
#-----Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	zplug install
fi
zplug load

#-------------------------------PREFER CODE
if [[ -f $(which code) ]]; then 
	export EDITOR='code -nw'
else
	export EDITOR='vim'
fi

#-------------------------------OPTIONS
COMPLETION_WAITING_DOTS="true"
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
export MANPAGER='less -X' # don't clear after quitting man

#------------------------------------PATHS ETC.
#[[ -d "/Volumes/Mac/Users/ian/" ]] && MYHD='/Volumes/Mac/Users/ian/' # old external HD
#[[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/" ]] && export MATLAB_JAVA="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home" # use installed JAVA
#[[ -d "/usr/local/share/zsh-completions/" ]] && fpath=(/usr/local/share/zsh-completions $fpath)
[[ -d "/opt/jdk-11/bin" ]] && path=("opt/jdk-11/bin" $path) # Linux JDK
[[ -d "/opt/jdk-11/bin" ]] && export JAVA_HOME="/opt/jdk-11/bin" # Linux Java
[[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]] && path=("/Applications/Araxis Merge.app/Contents/Utilities" $path)
[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path) # MacTeX
[[ -d "/Applications/MATLAB_R2018b.app/bin" ]] && path=("/Applications/MATLAB_R2018b.app/bin" $path) # matlab
[[ -d "/Applications/MATLAB_R2018b.app/bin" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2018b.app/bin/matlab" # matlab
[[ -x "/Applications/MATLAB_R2018b.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2018b.app/bin/maci64/mlint" ~/bin/mlint # matlab
if [[ -e "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
	source $HOME/miniconda3/etc/profile.d/conda.sh # miniconda, preferred way to use conda without mod path
	#conda activate base
elif [[ -d "$HOME/miniconda3/" ]]; then
	path=("$HOME/miniconda3/bin" $path) 
elif [[ -d "$HOME/anaconda3/" ]]; then
	path=("$HOME/anaconda3/bin" $path) 
fi
[[ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]] && path=("/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" $path)
[[ -d "/usr/local/sbin" ]] && path=("/usr/local/sbin" $path)
[[ -d "/opt/jdk-11/bin/" ]] && export PATH="/opt/jdk-11/bin/:$PATH" # Java
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