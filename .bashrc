export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)
export HOMEBREW_INSTALL_CLEANUP=true

#-------------------------------Bootstrap homebrew[s]
[[ $PLATFORM == 'Darwin' ]] && [[ -d /usr/local/homebrew ]] && eval "$(/usr/local/homebrew/bin/brew shellenv)"
[[ $PLATFORM == 'Darwin' ]] && [[ -d /opt/homebrew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ $PLATFORM == 'Linux' ]] && [[ -d /home/linuxbrew/.linuxbrew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

[[ $PLATFORM = 'darwin'* ]] && source $DF/myinfo

if [[ -f $(which nvim > /dev/null 2>&1) ]]; then
	export EDITOR='nvim'
elif [[ -f $(which vim > /dev/null 2>&1) ]]; then
	export EDITOR='vim'
fi

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"

export PATH=$HOME/bin:$HOME/scoop/shims:/usr/local/bin:/usr/local/sbin:$HOME:$PATH

#------------------------------------X-CMD SETUP
export ___X_CMD_HELP_LANGUAGE="en"
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

if [[ $PLATFORM == 'Darwin' ]]; then
	[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
	[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	[[ -d "/Applications/MATLAB_R2023a.app/bin" ]] && path=("/Applications/MATLAB_R2023a.app/bin" $path) # matlab
	[[ -x "/Applications/MATLAB_R2023a.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2023a.app/bin/maci64/mlint" ~/bin/mlint # matlab
else
	if [[ -d "/usr/local/MATLAB/R2023a/bin" ]]; then
		export PATH="/usr/local/MATLAB/R2023a/bin:$PATH" # matlab
		export MATLAB_EXECUTABLE="/usr/local/MATLAB/R2023a/bin" # matlab
		ln -sf "/usr/local/MATLAB/R2023a/bin/glnxa64/mlint" ~/bin/ # mlint
	fi
	[[ -d "/usr/lib/jvm/java-17-openjdk-amd64/bin/" ]] && export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64/" # Linux Java
	[[ -d "/usr/lib/jvm/java-17-openjdk-amd64/bin/" ]] && export PATH="${JAVA_HOME}bin:$PATH" # Linux JDK
	[[ -d "/home/linuxbrew/" ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if [[ -x $(which brew > /dev/null 2>&1) ]]; then
	[[ -d `brew --prefix`/etc/bash_completion.d ]] &&	source $(brew --prefix)/etc/bash_completion.d/*
fi

[[ -x $(which rbenv > /dev/null 2>&1) ]] && eval "$(rbenv init -)"
[[ -x $(which pyenv > /dev/null 2>&1) ]] && eval "$(pyenv init -)"
[[ -x $(which fzf > /dev/null 2>&1) ]] && eval <(fzf --bash)
[[ -f $(which starship > /dev/null 2>&1) ]] && eval "$(starship init bash)"
[[ -f "$DF/env" ]] && source "$DF/env"
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which figlet > /dev/null 2>&1) ]] && figlet "Totoro Hai!"
[[ -x $(which pkgx > /dev/null 2>&1) ]] && eval "$(pkgx --shellcode)"  #docs.pkgx.sh/shellcode
