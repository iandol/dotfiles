export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)
export HOMEBREW_INSTALL_CLEANUP=true

#-------------------------------Bootstrap homebrew[s]
[[ $PLATFORM == 'Darwin' ]] && [[ -f /usr/local/bin/brew ]] && [[ "$(arch)" == "i386" ]] && eval "$(/usr/local/bin/brew shellenv)"
[[ $PLATFORM == 'Darwin' ]] && [[ -d /opt/homebrew ]] && [[ "$(arch)" == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ $PLATFORM == 'Linux' ]] && [[ -d /home/linuxbrew/.linuxbrew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

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
HISTSIZE=20000
SAVEHIST=20000
HISTFILE=~/.zsh_history
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
([[ -x $(which brew) ]] && [[ -d "$(brew --prefix)/share/zsh/site-functions/" ]]) && fpath=("$(brew --prefix)/share/zsh/site-functions/" $fpath)

ul=("R2023b" "R2023a" "R2022b" "R2022a" "R2021b" "R2021a" "R2020b" "R2020a")
match=0
if [[ $PLATFORM == 'Darwin' ]]; then
	for x in $ul; do
		if ( [[ $match == 0 ]] && [[ -d "/Applications/MATLAB_${x}.app/bin" ]] ); then
			match=1
			path=("/Applications/MATLAB_${x}.app/bin" $path) # matlab
			export MATLAB_EXECUTABLE="/Applications/MATLAB_${x}.app/bin/matlab" # matlab
			ln -sf "/Applications/MATLAB_${x}.app/bin/maci64/mlint" ~/bin/mlint # matlab
		fi
	done
	#[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
	#[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	[[ -d "/Library/TeX/texbin" ]] && path+="/Library/TeX/texbin" # MacTeX
	[[ -d "/Library/Frameworks/GStreamer.framework/Commands" ]] && path+="/Library/Frameworks/GStreamer.framework/Commands" # GStreamer
else
	for x in $ul; do
		if ( [[ $match == 0 ]] && [[ -d "/usr/local/MATLAB/${x}/bin" ]]); then
			match=1
			path=("/usr/local/MATLAB/${x}/bin" $path) # matlab
			export MATLAB_EXECUTABLE="/usr/local/MATLAB/${x}/bin/matlab" # matlab
			ln -sf "/usr/local/MATLAB/${x}/bin/glnxa64/mlint" ~/bin/mlint &> /dev/null # matlab
		fi
	done
	[[ -d "/usr/lib/jvm/java-17-openjdk-amd64/bin/" ]] && export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64/" # Linux Java
	[[ -d "/usr/lib/jvm/java-17-openjdk-amd64/bin/" ]] && export path=("${JAVA_HOME}bin" $path) # Linux JDK
fi

# LUA
[[ -d "$HOME/.local/share/pandoc/filters" ]] && export LUA_PATH="$HOME/.local/share/pandoc/filters/?.lua;;"
[[ -d /opt/homebrew/share/lua/5.4 ]] && export LUA_PATH="/opt/homebrew/share/lua/5.4/?.lua;$LUA_PATH"
[[ -d /opt/homebrew/lib/lua/5.4 ]] && export LUA_CPATH="/opt/homebrew/lib/lua/5.4/?.so;/opt/homebrew/lib/lua/5.4/?/?.so;;"

# MicroMamba (Conda)
[[ -f "$HOME/.local/bin/micromamba" ]] && export MAMBA_EXE="$HOME/.local/bin/micromamba"
[[ -f "/opt/homebrew/bin/micromamba" ]] && export MAMBA_EXE="/opt/homebrew/bin/micromamba"
[[ -d "$HOME/micromamba" ]] && export MAMBA_ROOT_PREFIX="$HOME/micromamba"
[[ -d /media/cog/data/micromamba ]] && export MAMBA_ROOT_PREFIX="/media/cog/data/micromamba"
[[ -d /media/cogp/micromamba ]] && export MAMBA_ROOT_PREFIX="/media/cogp/micromamba"

if [[ -d $MAMBA_ROOT_PREFIX ]]; then
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
	eval "$__mamba_setup"
else
	alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
fi

#------------------------------------KITTY INTEGRATION
#if test -n "$KITTY_INSTALLATION_DIR"; then
#	export KITTY_SHELL_INTEGRATION="enabled"
#	autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
#	kitty-integration
#	unfunction kitty-integration
#fi

#------------------------------------FINALISE PATH
[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path)
[[ -d "$HOME/Library/TinyTeX/bin/universal-darwin" ]] && path+="$HOME/Library/TinyTeX/bin/universal-darwin"
[[ -d "/usr/local/sbin" ]] && path+="/usr/local/sbin"
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "/snap/bin" ]] && path=("/snap/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.cache/lm-studio/bin" ]] && path=("$PATH:$HOME/.cache/lm-studio/bin" $path)
export PATH

#------------------------------------FINALISE OTHERS
[[ -x $(which pyenv) ]] && eval "$(pyenv init - zsh)"
[[ -x $(which rbenv) ]] && eval "$(rbenv init - zsh)"
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
zi light zsh-users/zsh-completions
zicompinit # <- https://wiki.zshell.dev/docs/guides/commands
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
if [[ -f $(which starship) ]]; then
	eval "$(starship init zsh)"
else
	autoload -Uz promptinit; promptinit; prompt adam1
fi

#---------------------------------------SAY HELLO
echo "\n⌃a,e: ⇄ | ⌃w,k,u: 🔪 | ⌃r,s: 🔍 | d, cd - & cd #n: 🚀 | 💡 curl cheat.sh/?\n"

