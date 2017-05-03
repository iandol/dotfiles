#!/usr/bin/env zsh

echo "\n\n=====================setpath.sh @ $(date)" 

echo "\n---PATH: " $PATH 
echo "---PWD: " $PWD 
echo "---HOME: " $HOME 

echo "\n---1 $1 $2 $3 $4" 

export DROOPY=42
path=("/usr/local/bin" "$HOME/bin" $path)

[[ -d $HOME/anaconda3 ]] && path=("$HOME/anaconda3/bin" $path) # anaconda scientific python
[[ -d $HOME/.rbenv ]] && path=("$HOME/.rbenv/shims" $path) #ruby manager

export path

echo "\n---PATH: " $PATH 
echo "\n---DROOPY: " $DROOPY 

[[ -f $(which rbenv) ]] && rbenv local 2.4.1
[[ -f $(which rbenv) ]] && rbenv global 2.4.1

echo "---ruby: $(which ruby)" 
echo "---rbenv: $(which rbenv)" 
echo "---pandoc: $(which pandoc)" 
echo "---panzer: $(which panzer)" 
echo "---pandocomatic: $(which pandocomatic)" 

[[ -f $(which pandocomatic) ]] && pandocomatic -v 