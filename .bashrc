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

if [[ -e "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
  source $HOME/miniconda3/etc/profile.d/conda.sh # miniconda, preferred way to use conda without mod path
  conda activate base
elif [[ -d "$HOME/miniconda3/" ]]; then
  export PATH="$HOME/miniconda3/bin:$PATH"
elif [[ -d "$HOME/anaconda3/" ]]; then
  export PATH="$HOME/anaconda3/bin:$PATH"
fi

[[ -d "/opt/jdk-11/bin/" ]] && export PATH="/opt/jdk-11/bin:$PATH" # Linux Java
[[ -d "/opt/jdk-11/bin/" ]] && export JAVA_HOME="/opt/jdk-11/bin" # Linux Java

[[ -d "/home/linuxbrew/.linuxbrew/bin/" ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
if [[ -x $(which brew) ]]; then
	[[ -f `brew --prefix`/etc/bash_completion ]] &&	source `brew --prefix`/etc/bash_completion
fi

[[ -x $(which rbenv) ]] && eval "$(rbenv init -)"
[ -x $(which fzf) ] && source $DF/.fzf.bash
[[ -f "$DF/env" ]] && source "$DF/env"
[[ -f "$DF/aliases" ]] && source "$DF/aliases"
[[ -x $(which figlet) ]] && figlet "Tarako Hai!"
