source ~/.bash/env
source ~/.bash/aliases
source ~/.bash/config

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

figlet "Hello Master..."

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"