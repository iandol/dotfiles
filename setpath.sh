#!/usr/bin/env zsh

echo "\n\n=======================$(date)" >> ~/Desktop/out.log 2>&1

echo "\n---PATH: " $PATH >> ~/Desktop/out.log 2>&1
echo "---PWD: " $PWD >> ~/Desktop/out.log 2>&1
echo "---HOME: " $HOME >> ~/Desktop/out.log 2>&1

echo "\n---1 $1 $2 $3 $4" >> ~/Desktop/out.log 2>&1

export DROOPY=42
path=("/usr/local/bin" "$HOME/bin" $path)
path=("$HOME/anaconda3/bin" $path)

[[ -d $HOME/anaconda3 ]] && path=("$HOME/anaconda3/bin" $path) # anaconda scientific python
[[ -d $HOME/.rbenv ]] && path=("$HOME/.rbenv/shims" $path) #ruby manager

export $path

echo "\n---PATH: " $PATH >> ~/Desktop/out.log 2>&1
echo "\n---DROOPY: " $DROOPY >> ~/Desktop/out.log 2>&1

[[ -f $(which rbenv) ]] && rbenv local 2.4.1
[[ -f $(which rbenv) ]] && rbenv global 2.4.1

echo "---ruby: $(which ruby)" >> ~/Desktop/out.log 2>&1
echo "---rbenv: $(which rbenv)" >> ~/Desktop/out.log 2>&1
echo "---pandoc: $(which pandoc)" >> ~/Desktop/out.log 2>&1
echo "---panzer: $(which panzer)" >> ~/Desktop/out.log 2>&1
echo "---pandocomatic: $(which pandocomatic)" >> ~/Desktop/out.log 2>&1

pandocomatic -v >> ~/Desktop/out.log 2>&1