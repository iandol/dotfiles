export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)
export HOMEBREW_INSTALL_CLEANUP=true

#-------------------------------PREFER nvim
if [[ -f $(which nvim) ]]; then
	export EDITOR='nvim'
elif [[ -f $(which vim) ]]; then
	export EDITOR='vim'
fi

#-------------------------------ZSH OPTIONS
COMPLETION_WAITING_DOTS="true"
DIRSTACKSIZE=20 # pushd stacksize
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_MINUS PUSHD_SILENT 
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=20000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_GLOB
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
export MANPAGER='less -X'        # don't clear after quitting man
typeset -U PATH path             # don't allow duplicates in path

unalias run-help >& /dev/null
autoload run-help # use ESC + H to bring up help, see https://man.archlinux.org/man/extra/zsh/zshcontrib.1.en
alias help=run-help

#------------------------------------PATHS/ENVS ETC.
([[ -f $(which brew) ]] && [[ -d "$(brew --prefix)/share/zsh/site-functions/" ]]) && fpath=("$(brew --prefix)/share/zsh/site-functions/" $fpath)

if [[ $PLATFORM == 'Darwin' ]]; then
#	[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
#	[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	ul=("R2022b" "R2022a" "R2021b" "R2021a" "R2020b" "R2020a")
	match=0
	for x in $ul; do
		if ( [[ $match == 0 ]] && [[ -d "/Applications/MATLAB_${x}.app/bin" ]] ); then
			match=1
			path=("/Applications/MATLAB_${x}.app/bin" $path) # matlab
			export MATLAB_EXECUTABLE="/Applications/MATLAB_${x}.app/bin/matlab" # matlab
			ln -sf "/Applications/MATLAB_${x}.app/bin/maci64/mlint" ~/bin/mlint # matlab
		fi
	done
	[[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]] && path+="/Applications/Araxis Merge.app/Contents/Utilities"
	[[ -d "/Library/TeX/texbin" ]] && path+="/Library/TeX/texbin" # MacTeX
	[[ -d "/Library/Frameworks/GStreamer.framework/Commands" ]] && path+="/Library/Frameworks/GStreamer.framework/Commands" # GStreamer
else
	[[ -d "/usr/lib/jvm/java-17-openjdk-amd64/bin/" ]] && export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64/" # Linux Java
	[[ -d "/usr/lib/jvm/java-17-openjdk-amd64/bin/" ]] && export path=("${JAVA_HOME}bin" $path) # Linux JDK
	ul=("R2022b" "R2022a" "R2021b" "R2021a" "R2020b" "R2020a")
	match=0
	for x in $ul; do
		if ( [[ $match == 0 ]] && [[ -d "/usr/local/MATLAB/${x}/bin" ]]); then
			match=1
			path=("/usr/local/MATLAB/${x}/bin" $path) # matlab
			export MATLAB_EXECUTABLE="/usr/local/MATLAB/${x}/bin/matlab" # matlab
			ln -sf "/usr/local/MATLAB/${x}/bin/glnxa64/mlint" ~/bin/mlint &> /dev/null # matlab
		fi
	done
	[[ -d "/home/linuxbrew/.linuxbrew" ]] && path=("/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $path)
fi

if [[ -d "$HOME/miniconda3/" ]]; then
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
			path=("$HOME/miniconda3/bin" $path)
		fi
	fi
	unset __conda_setup
	# <<< conda initialize <<<
fi

#------------------------------------FINALISE PATH
[[ -d "/usr/local/sbin" ]] && path+="/usr/local/sbin"
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
export PATH

#------------------------------------FINALISE OTHERS
[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
#[[ -x $(which archey) ]] && archey -c -o
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which fzf) ]] && source $DF/configs/.fzf.zsh

#-------------------------------------ZINIT SETUP
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi
# examples here -> https://wiki.zshell.dev/ecosystem/category/-annexes
zicompinit # <- https://wiki.zshell.dev/docs/guides/commands
zi light zsh-users/zsh-completions
zi light zsh-users/zsh-history-substring-search
zi light z-shell/H-S-MW 
zi light z-shell/F-Sy-H 
zi light zsh-users/zsh-autosuggestions

if [[ $PLATFORM = 'Darwin' ]]; then
	bindkey "^[[A" history-substring-search-up
	bindkey "^[[B" history-substring-search-down
else
	bindkey "$terminfo[kcuu1]" history-substring-search-up # see https://github.com/zsh-users/zsh-history-substring-search/issues/92
	bindkey "$terminfo[kcud1]" history-substring-search-down
fi
### End of Zi's installer chunk

#---------------------------------------STARSHIP
[[ -f $(which starship) ]] && eval "$(starship init zsh)"

#---------------------------------------SAY HELLO
echo "\n⌃a,e: ⇄ | ⌃w,k,u: 🔪 | ⌃r,s: 🔍 | d, cd - & cd #n: 🚀 | 💡 curl cheat.sh/?\n"
