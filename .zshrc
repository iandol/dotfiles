export DF="$HOME/.dotfiles"
export PLATFORM="$(uname -s)"
export HOMEBREW_INSTALL_CLEANUP=true

#-------------------------------Bootstrap homebrew[s]
[[ $PLATFORM == 'Darwin' ]] && [[ "$(arch)" == "i386" ]] && [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
[[ $PLATFORM == 'Darwin' ]] && [[ "$(arch)" == "arm64" ]] && [[ -d /opt/homebrew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ $PLATFORM == 'Linux' ]] && [[ -d /home/linuxbrew/.linuxbrew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#------------------------------------X-CMD SETUP
export ___X_CMD_LANG="en"
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

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
setopt extended_glob
setopt extended_history 
setopt hist_expire_dups_first	# Expire duplicate entries first when trimming history.
setopt hist_ignore_dups			# Don't record an entry that was just recorded again.
setopt hist_ignore_all_dups		# Delete old recorded entry if new entry is a duplicate.
setopt hist_ignore_space		# Don't record an entry starting with a space.
setopt hist_save_no_dups		# Don't write duplicate entries in the history file.
setopt hist_reduce_blanks		# Remove superfluous blanks before recording entry.
setopt inc_append_history     	# write to the history file immediately, not when the shell exits.
setopt share_history          	# share command history dataexport MANPAGER='less -X'        # don't clear after quitting man
typeset -U PATH path			# don't allow duplicates in path

unalias run-help >& /dev/null
autoload run-help # use ESC + H to bring up help, see https://man.archlinux.org/man/extra/zsh/zshcontrib.1.en
alias help=run-help

#------------------------------------PATHS/ENVS ETC.
([[ -x $(which brew) ]] && [[ -d "$(brew --prefix)/share/zsh/site-functions/" ]]) && fpath=("$(brew --prefix)/share/zsh/site-functions/" $fpath)

ul=("R2025b" "R2025a" "R2024b" "R2024a" "R2023b" "R2023a" "R2022b" "R2022a" "R2021b" "R2021a" "R2020b" "R2020a")
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
#------------------------------------LUA
[[ -d "$HOME/.local/share/pandoc/filters" ]] && export LUA_PATH="$HOME/.local/share/pandoc/filters/?.lua;;"
[[ -d /opt/homebrew/share/lua/5.4 ]] && export LUA_PATH="/opt/homebrew/share/lua/5.4/?.lua;$LUA_PATH"
[[ -d /opt/homebrew/lib/lua/5.4 ]] && export LUA_CPATH="/opt/homebrew/lib/lua/5.4/?.so;/opt/homebrew/lib/lua/5.4/?/?.so;;"

#------------------------------------FINALISE PATH
[[ -d "/Library/TeX/texbin" ]] && path=("/Library/TeX/texbin" $path)
[[ -d "$HOME/Library/TinyTeX/bin/universal-darwin" ]] && path+="$HOME/Library/TinyTeX/bin/universal-darwin"
[[ -d "/usr/local/sbin" ]] && path=("/usr/local/sbin" $path)
[[ -d "/usr/local/bin" ]] && path=("/usr/local/bin" $path)
[[ -d "/opt/homebrew/opt/ruby/bin" ]] && path=("/opt/homebrew/opt/ruby/bin" $path)
[[ -d "/opt/homebrew/lib/ruby/gems/3.4.0/bin" ]] && path=("/opt/homebrew/lib/ruby/gems/3.4.0/bin" $path)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "/snap/bin" ]] && path=("/snap/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.cache/lm-studio/bin" ]] && path=("$HOME/.cache/lm-studio/bin" $path)
[[ -d "$HOME/.pixi/envs/ruby/share/rubygems/bin" ]] && path=("$HOME/.pixi/envs/ruby/share/rubygems/bin" $path)
[[ -d "$HOME/.pixi/bin" ]] && path=("$HOME/.pixi/bin" $path)
export path

#------------------------------------FINALISE OTHERS
[[ -x $(which pyenv) ]] && eval "$(pyenv init - zsh)"
[[ -x $(which rbenv) ]] && eval "$(rbenv init - zsh)"
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which fzf) ]] && source <(fzf --zsh)
[[ -x $(which pkgx) ]] && source <(pkgx --shellcode)  #docs.pkgx.sh/shellcode
[[ -x $(which pixi) ]] && eval "$(pixi completion --shell zsh)"

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
#zi light z-shell/H-S-MW 
zi light z-shell/F-Sy-H 
zi light zsh-users/zsh-autosuggestions
### End of Zi's installer chunk

#---------------------------------------STARSHIP
if [[ -f $(which starship) ]]; then
	eval "$(starship init zsh)"
else
	autoload -Uz promptinit; promptinit; prompt adam1
fi

#---------------------------------------SAY HELLO
echo "\n⌃a,e: ⇄ | ⌃w,k,u: 🔪 | ⌃r,s: 🔍 | d, cd - & cd #n: 🚀 | 💡 curl cheat.sh/?\n"


