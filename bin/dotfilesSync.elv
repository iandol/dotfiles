#!/usr/bin/env elvish
# Sync my codeberg dotfiles repo back to github

set-env PATH "/Users/ian/.pixi/bin:/opt/homebrew/bin:/Users/ian/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:"$E:PATH
cd ~/Code/dotfiles
git status 
ssh-add -v /Users/ian/.ssh/gitrepo2
ssh-add -v /Users/ian/.ssh/gitrepo
ssh-add -l
git remote -v
git fetch -v --all
git merge codeberg/main
git push origin main
