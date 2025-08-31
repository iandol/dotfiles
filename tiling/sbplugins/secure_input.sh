#!/bin/bash

secure_input_enabled=$(ioreg -l -w 0 | grep SecureInput)
pid=$(echo "$secure_input_enabled" | sed -n 's/.*PID"=\([0-9]\{1,\}\).*/\1/p' | head -n 1)

if [ -n "$secure_input_enabled" ]; then
  COLOR=0xFFFF4444
  LABEL="󰌓  $pid"
else
  COLOR=0xAA000000
fi

sketchybar --set $NAME label="$LABEL" icon.color="$COLOR" label.color="$COLOR"
