#!/usr/bin/env elvish
# Sync my codeberg dotfiles repo back to github

set-env PATH "/Users/ian/.pixi/bin:/opt/homebrew/bin:/Users/ian/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:"$E:PATH
cd ~/Code/dotfiles
ssh-add -v ~/.ssh/gitrepo2
ssh-add -v ~/.ssh/gitrepo
ssh-add -l
git fetch -v codeberg
git merge codeberg/main
git push origin main
