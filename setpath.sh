#!/usr/bin/env zsh

echo "\n\n=======================" >> ~/Desktop/out.log 2>&1

echo "\n---PATH: " $PATH >> ~/Desktop/out.log 2>&1
echo "---PWD: " $PWD >> ~/Desktop/out.log 2>&1
echo "---HOME: " $HOME >> ~/Desktop/out.log 2>&1

echo "\n---1 $1 $2 $3 $4" >> ~/Desktop/out.log 2>&1

export DROOPY=42
export PATH=$HOME/.rbenv/shims:/usr/local/bin:$HOME/bin:$PATH

echo "\n---PATH: " $PATH >> ~/Desktop/out.log 2>&1
echo "\n---DROOPY: " $DROOPY >> ~/Desktop/out.log 2>&1

rbenv local 2.4.1
rbenv global 2.4.1

echo "---ruby: $(which ruby)" >> ~/Desktop/out.log 2>&1
echo "---rbenv: $(which rbenv)" >> ~/Desktop/out.log 2>&1
echo "---pandoc: $(which pandoc)" >> ~/Desktop/out.log 2>&1
echo "---panzer: $(which panzer)" >> ~/Desktop/out.log 2>&1
echo "---pandocomatic: $(which pandocomatic)" >> ~/Desktop/out.log 2>&1

pandocomatic -v >> ~/Desktop/out.log 2>&1