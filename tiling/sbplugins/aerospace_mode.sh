#!/usr/bin/env bash

CURRENT_MODE=$(aerospace list-modes --current)

if [ "$CURRENT_MODE" == "main" ]; then
	sketchybar --bar color=0x66000000 --set "$NAME" drawing=off
else
	sketchybar --bar color=0x66cc5555 --set "$NAME" drawing=on
fi
