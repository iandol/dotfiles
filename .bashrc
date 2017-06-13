source ~/.dotfiles/env
source ~/.dotfiles/aliases
[[ $OSTYPE = 'darwin'* ]] && source ~/.dotfiles/config

# Make vim the default editor
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
[[ -d "$HOME/miniconda3/" ]] && export PATH="$HOME/miniconda3/bin:$PATH" #anaconda scientific python

if [[ -f $(which brew) ]]; then
	if [[ -f `brew --prefix`/etc/bash_completion ]]; then
		source `brew --prefix`/etc/bash_completion
	fi
fi

[[ -f $(which figlet) ]] && figlet "Tarako Hai!"
[[ -f $(which rbenv) ]] && eval "$(rbenv init -)"
