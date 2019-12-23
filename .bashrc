export DF="$HOME/.dotfiles"
export PLATFORM=$(uname -s)

[[ $PLATFORM = 'darwin'* ]] && source $DF/config

# Make sublime the default editor
if [[ -f $(which subl) ]]; then 
	export EDITOR="subl -w"
else
	export EDITOR="vim"
fi

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"

export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$HOME:$PATH

if type brew 2&>/dev/null; then
  source "$(brew --prefix)/etc/bash_completion.d/*"
else
  echo "run: brew install git bash-completion"
fi

if [[ $PLATFORM == 'Darwin' ]]; then
	[[ -d `/usr/libexec/java_home` ]] && export JAVA_HOME=`/usr/libexec/java_home`
	[[ -d $JAVA_HOME ]] && path=(${JAVA_HOME}/bin $path)
	[[ -d "/Applications/MATLAB_R2018b.app/bin" ]] && path=("/Applications/MATLAB_R2018b.app/bin" $path) # matlab
	[[ -d "/Applications/MATLAB_R2018b.app/bin" ]] && export MATLAB_EXECUTABLE="/Applications/MATLAB_R2018b.app/bin/matlab" # matlab
	[[ -x "/Applications/MATLAB_R2018b.app/bin/maci64/mlint" ]] && ln -sf "/Applications/MATLAB_R2018b.app/bin/maci64/mlint" ~/bin/mlint # matlab
	[[ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]] && path=("/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" $path)
else
	[[ -d "/opt/jdk-11/bin" ]] && export JAVA_HOME="/opt/jdk-11/" # Linux Java
	[[ -d "/opt/jdk-11/bin" ]] && path=(${JAVA_HOME}bin $path) # Linux JDK
	[[ -d "/home/linuxbrew/.linuxbrew/bin/" ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if [[ -x $(which brew) ]]; then
	[[ -d `brew --prefix`/etc/bash_completion.d ]] &&	source `brew --prefix`/etc/bash_completion.d/*
fi

[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
[ -x $(which fzf) ] && source $DF/.fzf.bash
[[ -f "$DF/env" ]] && source "$DF/env"
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which figlet) ]] && figlet "Totoro Hai!"
