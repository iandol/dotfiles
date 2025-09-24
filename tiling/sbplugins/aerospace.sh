#!/usr/bin/env bash

# Use the environment variable passed by aerospace trigger, fallback to direct call
CURRENT=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}

# Extract workspace name from item name (space.WORKSPACE_NAME)
WORKSPACE_NAME=${NAME#space.}

# Check if this workspace has any windows
WINDOW_COUNT=$(aerospace list-windows --workspace "$WORKSPACE_NAME" 2>/dev/null | wc -l)

# Check if this workspace is the currently focused one
if [ "$WORKSPACE_NAME" = "$CURRENT" ]; then
    # This is the active workspace - highlight it with background
    sketchybar --set $NAME \
        label="$WORKSPACE_NAME" \
        label.color=0xffffffff \
        label.font.size=11 \
        background.drawing=on \
        background.color=0xff0F574F \
        background.corner_radius=4 \
        background.height=18 \
        background.border_width=0
elif [ "$WINDOW_COUNT" -gt 0 ]; then
    # This workspace has windows but is not active - show with darker background
    sketchybar --set $NAME \
        label="$WORKSPACE_NAME" \
        label.color=0xffffffff \
        label.font.size=11 \
        background.drawing=on \
        background.color=0xff09342F \
        background.corner_radius=4 \
        background.height=18 \
        background.border_width=0 \
        padding_left=3 \
        padding_right=3
else
    # This is an empty workspace - show as dimmed without background
    sketchybar --set $NAME \
        label="$WORKSPACE_NAME" \
        label.color=0x88ffffff \
        label.font.size=11 \
        background.drawing=off \
        padding_left=3 \
        padding_right=3
fi
