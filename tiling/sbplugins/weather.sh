#!/bin/zsh

raw=$(curl "https://wttr.in/Shanghai?format=%c%f%20%p%20%m")
[[ "$raw" =~ "^(Unknown|This)" ]] && raw="?"
[[ -z "$raw" ]] && exit 1
sketchybar --set $NAME label="$raw"
