#!/usr/bin/env bash

CURRENT_MODE=$(aerospace list-modes --current)

if [ "$CURRENT_MODE" == "main" ]; then
	sketchybar --bar color=0x66000000 --set "$NAME" drawing=off
elif [ "$CURRENT_MODE" == "service" ]; then
	sketchybar --bar color=0x66cc5555 --set "$NAME" drawing=on
else
	sketchybar --bar color=0x6600ffaa --set "$NAME" drawing=on
fi
