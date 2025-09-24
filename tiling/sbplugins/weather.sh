#!/bin/zsh

raw=$(curl "https://wttr.in/Shanghai?format=%c%f%p%m")
[[ "$raw" =~ "^Unknown" ]] && raw="❓"
[[ -z "$raw" ]] && exit 1
sketchybar --set $NAME label="$raw"
