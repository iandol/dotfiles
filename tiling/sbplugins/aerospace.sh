#!/usr/bin/env bash

ACTIVE_COLOR=0xbbBB9988
NOTEMPTY_COLOR=0x77777777

# Use the environment variable passed by aerospace trigger, fallback to direct call
CURRENT=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}

# Extract workspace name from item name (space.WORKSPACE_NAME)
WORKSPACE_NAME=${NAME#space.}

# Check if this workspace has any windows
WINDOW_COUNT=$(aerospace list-windows --workspace "$WORKSPACE_NAME" 2>/dev/null | wc -l | xargs)

# Check if this workspace is the currently focused one
if [ "$WORKSPACE_NAME" = "$CURRENT" ]; then
	# This is the active workspace - highlight it with background
	sketchybar --set $NAME \
		label="$WORKSPACE_NAME" \
		label.color=0xffffffff \
		background.drawing=on \
		background.color=$ACTIVE_COLOR \
		background.border_width=0 \
		label.font.size=14
elif [ "$WINDOW_COUNT" -gt 0 ]; then
	# This workspace has windows but is not active - show with darker background
	sketchybar --set $NAME \
		label="$WORKSPACE_NAME" \
		label.color=0xccffffff \
		background.drawing=on \
		background.color=$NOTEMPTY_COLOR \
		background.border_width=0 \
		label.font.size=12
else
	# This is an empty workspace - show as dimmed without background
	sketchybar --set $NAME \
		label="$WORKSPACE_NAME" \
		label.color=0x66ffffff \
		background.drawing=off \
		label.font.size=11
fi
