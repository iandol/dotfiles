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
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
export SPACESHIP_CONDA_SHOW='false'
#"dracula/zsh" | "mashaal/wild-cherry/zsh", from:github, use:wild-cherry.zsh-theme, as:theme 
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

#-------------------------------PREFER VSCODE
if [[ -f $(which code) ]]; then 
	export EDITOR='code -nw'
elif [[ -f $(which micro) ]]; then
	export EDITOR='micro'
else
	export EDITOR='nano'
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
export MANPAGER='less -X'        # don't clear after quitting man
typeset -U path                  # don't allow duplicates in path

#------------------------------------PATHS/ENVS ETC.
([[ -f $(which brew) ]] && [[ -d "$(brew --prefix)/share/zsh/site-functions/" ]]) && fpath=("$(brew --prefix)/share/zsh/site-functions/" $fpath)

if [[ $PLATFORM == 'Darwin' ]]; then
#	[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
#	[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	if [[ -d "/Applications/MATLAB_R2020b.app/bin" ]]; then
		path+="/Applications/MATLAB_R2020b.app/bin" # matlab
		export MATLAB_EXECUTABLE="/Applications/MATLAB_R2020b.app/bin/matlab" # matlab
		ln -sf "/Applications/MATLAB_R2020b.app/bin/maci64/mlint" ~/bin/mlint # matlab
	elif [[ -d "/Applications/MATLAB_R2020a.app/bin" ]]; then
		path+="/Applications/MATLAB_R2020a.app/bin" # matlab
		export MATLAB_EXECUTABLE="/Applications/MATLAB_R2020a.app/bin/matlab" # matlab
		ln -sf "/Applications/MATLAB_R2020a.app/bin/maci64/mlint" ~/bin/mlint # matlab
	fi
	[[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]] && path+="/Applications/Araxis Merge.app/Contents/Utilities"
	[[ -d "/Library/TeX/texbin" ]] && path+="/Library/TeX/texbin" # MacTeX
	[[ -d "/Library/Frameworks/GStreamer.framework/Commands" ]] && path+="/Library/Frameworks/GStreamer.framework/Commands" # GStreamer
	if [[ -d /Applications/ZeroBraneStudio.app ]]; then
		export ZBS=/Applications/ZeroBraneStudio.app/Content/ZeroBraneStudio
		#export LUA_PATH="/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;/usr/local/lib/lua/5.3/?.lua;/usr/local/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua;./?.lua;$ZBS/lualibs/?/?.lua;$ZBS/lualibs/?.lua"
		#export LUA_CPATH="/usr/local/lib/lua/5.3/?.so;/usr/local/lib/lua/5.3/?/?.so;/usr/local/lib/lua/5.3/loadall.so;./?.so;$ZBS/bin/?.dylib;$ZBS/bin/clibs53/?.dylib;$ZBS/bin/clibs53/?/?.dylib"
	fi
else
	if [[ -d "/usr/local/MATLAB/R2020b/bin" ]]; then
		path+="/usr/local/MATLAB/R2020b/bin" # matlab
		export MATLAB_EXECUTABLE="/usr/local/MATLAB/R2020b/bin" # matlab
		ln -sf "/usr/local/MATLAB/R2020b/bin/glnxa64/mlint" ~/bin/ # mlint
	elif [[ -d "/usr/local/MATLAB/R2020b/bin" ]]; then
		path+="/usr/local/MATLAB/R2020a/bin" # matlab
		export MATLAB_EXECUTABLE="/usr/local/MATLAB/R2020a/bin" # matlab
		ln -sf "/usr/local/MATLAB/R2020a/bin/glnxa64/mlint" ~/bin/ # mlint
	fi
	[[ -d "/opt/jdk-11/bin" ]] && export JAVA_HOME="/opt/jdk-11/" # Linux Java
	[[ -d "/opt/jdk-11/bin" ]] && path+=${JAVA_HOME}bin # Linux JDK
	[[ -d "/home/linuxbrew/.linuxbrew" ]] && path=("/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $path)
fi

#-------------------------------------CONDA
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        path+="$HOME/ian/miniconda3/bin"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#------------------------------------FINALISE PATH
[[ -d "/usr/local/sbin" ]] && path+="/usr/local/sbin"
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
export PATH

#------------------------------------FINALISE OTHERS
[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
[[ -x $(which archey) ]] && archey -c -o
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which fzf) ]] && source $DF/.fzf.zsh

echo "⌃a,e: ⇄ | ⌃w,k,u: 🔪 | ⌃r,s: ↑↓🔍 | d, cd - & cd #n: 🚀 | 💡 tldr ? / curl cheat.sh/?"