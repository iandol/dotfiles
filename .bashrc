export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)

[[ $PLATFORM = 'darwin'* ]] && source $DF/myinfo

# Make sublime the default editor
export EDITOR="nvim"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"

export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$HOME:$PATH

if [[ $PLATFORM == 'Darwin' ]]; then
	[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
	[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	[[ -d "/Applications/MATLAB_R2020b.app/bin" ]] && path=("/Applications/MATLAB_R2018b.app/bin" $path) # matlab
	[[ -d "/Applications/MATLAB_R2020b.app/bin" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2020b.app/bin/matlab" # matlab
	[[ -x "/Applications/MATLAB_R2020b.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2020b.app/bin/maci64/mlint" ~/bin/mlint # matlab
	[[ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]] && path=("/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" $path)
else
	if [[ -d "/usr/local/MATLAB/R2020b/bin" ]]; then
		export PATH="/usr/local/MATLAB/R2020b/bin:$PATH" # matlab
		export MATLAB_EXECUTABLE="/usr/local/MATLAB/R2020b/bin" # matlab
		ln -sf "/usr/local/MATLAB/R2020b/bin/glnxa64/mlint" ~/bin/ # mlint
	elif [[ -d "/usr/local/MATLAB/R2020a/bin" ]]; then
		export PATH="/usr/local/MATLAB/R2020a/bin:$PATH" # matlab
		export MATLAB_EXECUTABLE="/usr/local/MATLAB/R2020a/bin" # matlab
		ln -sf "/usr/local/MATLAB/R2020a/bin/glnxa64/mlint" ~/bin/ # mlint
	fi
	[[ -d "/usr/lib/jvm/java-15-openjdk-amd64/bin/" ]] && export JAVA_HOME="/usr/lib/jvm/java-15-openjdk-amd64/" # Linux Java
	[[ -d "/usr/lib/jvm/java-15-openjdk-amd64/bin/" ]] && export PATH="${JAVA_HOME}bin:$PATH" # Linux JDK
	[[ -d "/home/linuxbrew/.linuxbrew/bin/" ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if [[ -x $(which brew) ]]; then
	[[ -d `brew --prefix`/etc/bash_completion.d ]] &&	source $(brew --prefix)/etc/bash_completion.d/*
fi

[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
[ -x $(which fzf) ] && source $DF/configs/.fzf.bash
[[ -f "$DF/env" ]] && source "$DF/env"
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which figlet) ]] && figlet "Totoro Hai!"
