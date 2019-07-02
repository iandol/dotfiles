#!/usr/bin/env zsh

export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)
export HOMEBREW_INSTALL_CLEANUP=true

#======================ZPLUG SETUP==============
export ZPLUG_HOME=~/.zplug
source $ZPLUG_HOME/init.zsh
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
#-----if fzf is not installed
[[ ! -x $(which fzf) ]] && zplug "zdharma/history-search-multi-word" 
[[ ! -x $(which fzf) ]] && zstyle ":plugin:history-search-multi-word" clear-on-cancel "yes"
#-----Load theme file
#zplug "dracula/zsh", as:theme #zplug "agkozak/agkozak-zsh-theme" #zplug "mashaal/wild-cherry/zsh", from:github, use:wild-cherry.zsh-theme, as:theme #zplug "eendroroy/alien-minimal", from:github, as:theme #zplug "eendroroy/alien", from:github, as:theme
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
#zplug "mafredri/zsh-async"
#zplug "sindresorhus/pure", use:pure.zsh, as:theme
#-----supposed to come after compinit
zplug "zdharma/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3
if [[ $PLATFORM = 'Darwin' ]]; then
	bindkey "^[[A" history-substring-search-up
	bindkey "^[[B" history-substring-search-down
else
	bindkey "$terminfo[kcuu1]" history-substring-search-up # see https://github.com/zsh-users/zsh-history-substring-search/issues/92
	bindkey "$terminfo[kcud1]" history-substring-search-down
fi
#-----Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	zplug install
fi
zplug load
#===============================================

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

#------------------------------------PATHS/ENVS ETC.
[[ -d "$(brew --prefix)/share/zsh/site-functions/" ]] && fpath=("$(brew --prefix)/share/zsh/site-functions/" $fpath)

if [[ $PLATFORM == 'Darwin' ]]; then
	[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
	[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	[[ -d "/Applications/MATLAB_R2019a.app/bin" ]] && path=("/Applications/MATLAB_R2019a.app/bin" $path) # matlab
	[[ -d "/Applications/MATLAB_R2019a.app/bin" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2019a.app/bin/matlab" # matlab
	[[ -x "/Applications/MATLAB_R2019a.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2019a.app/bin/maci64/mlint" ~/bin/mlint # matlab
	[[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]] && path=("/Applications/Araxis Merge.app/Contents/Utilities" $path)
	[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path) # MacTeX
else
	[[ -d "/opt/jdk-11/bin" ]] && export JAVA_HOME="/opt/jdk-11/" # Linux Java
	[[ -d "/opt/jdk-11/bin" ]] && path=(${JAVA_HOME}bin $path) # Linux JDK
	[[ -d "/home/linuxbrew/.linuxbrew" ]] && path=("/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $path)
fi

#-------------------------------------CONDA
if [[ -e "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
	source $HOME/miniconda3/etc/profile.d/conda.sh # miniconda, preferred way to use conda without mod path
	#conda activate base
elif [[ -d "$HOME/miniconda3/" ]]; then
	path=("$HOME/miniconda3/bin" $path) 
elif [[ -d "$HOME/anaconda3/" ]]; then
	path=("$HOME/anaconda3/bin" $path) 
fi

#------------------------------------FINALISE PATH
[[ -d "/usr/local/sbin" ]] && path=("/usr/local/sbin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
export PATH

#------------------------------------FINALISE OTHERS
[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
[[ -x $(which archey) ]] && archey -c -o
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which fzf) ]] && source $DF/.fzf.zsh

echo "⌃a,e: ⇄ | ⌃w,k,u: 🔪 | ⌃r,s: ↑↓🔍 | d, cd - & cd #n: 🚀 | 💡 tldr ? / curl cheat.sh/?"
