#! /bin/bash
# window_title.sh

WIN_TITLE_FILE='/tmp/window_title.dat'

WINDOW_TITLE=$(/opt/homebrew/bin/aerospace list-windows --focused --format '%{app-name}:%{window-title}')

if [[ $WINDOW_TITLE = "" ]]; then
  WINDOW_TITLE=$(/opt/homebrew/bin/aerospace list-windows --focused --format '%{app-name}')
fi

OLD_TITLE=$(cat $WIN_TITLE_FILE)

if [[ $WINDOW_TITLE = $OLD_TITLE ]]; then
  exit 0
else
  sketchybar --animate sin 5 --set title label.color.alpha=0.0 label.width=0
  echo $WINDOW_TITLE > $WIN_TITLE_FILE
  
  sleep 0.15
  
  sketchybar -m --set title label="$WINDOW_TITLE"
  sketchybar --animate sin 5 --set title label.color.alpha=1.0 label.width=dynamic
fi
