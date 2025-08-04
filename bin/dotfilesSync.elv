#!/usr/bin/env elvish
# Sync my codeberg dotfiles repo back to github

set-env PATH "/Users/ian/.pixi/bin:/opt/homebrew/bin:/Users/ian/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd ~/Code/dotfiles
git fetch codeberg
git merge codeberg/main
git push origin main
