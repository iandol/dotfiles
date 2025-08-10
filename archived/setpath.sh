#!/usr/bin/env zsh

echo "\n\n=====================setpath.sh @ $(date)" 

echo "\n---PATH: " $PATH 
echo "---PWD: " $PWD 
echo "---HOME: " $HOME 

echo "\n---1 $1 $2 $3 $4" 

export DROOPY=42
path=("/opt/homebrew/bin" "/usr/local/bin" "$HOME/bin" $path)

[[ -d $HOME/miniconda ]] && path=("$HOME/miniconda/bin" $path) # anaconda scientific python
[[ -d $HOME/.rbenv ]] && path=("$HOME/.rbenv/shims" $path) #ruby manager

export path

echo "\n---MODIFIED PATH: " $PATH 
echo "\n---DROOPY: " $DROOPY 

#[[ -f $(which rbenv) ]] && rbenv local system
#[[ -f $(which rbenv) ]] && rbenv global system

echo "---ruby: $(which ruby)" 
echo "---rbenv: $(which rbenv)" 
echo "---pandoc: $(which pandoc)" 
echo "---panzer: $(which panzer)" 
echo "---pandocomatic: $(which pandocomatic)" 

[[ -f $(which pandocomatic) ]] && pandocomatic -v 