#!/bin/bash
# brew install media-control jq

ICON_PLAY="  "
ICON_PAUSE=" "
ICON_NOMEDIA="󰝛 "
MEDIA_JSON=$(/opt/homebrew/bin/media-control get)
X=$(echo "$MEDIA_JSON" | jq -r '.bundleIdentifier')

# Default case for fallback
if [ -z "$MEDIA_JSON" ]; then
  sketchybar --set $NAME icon="$ICON_PLAY" \
                         label="Player Not Open" \
                         drawing=on
  exit 0
fi
BUNDLE_ID=$(echo "$MEDIA_JSON" | jq -r '.bundleIdentifier')
PLAYBACK_RATE=$(echo "$MEDIA_JSON" | jq -r '.playbackRate')
LABEL=$(echo "$MEDIA_JSON" | jq -r '.title + "—" + .artist + "—" + .album')

# Check if the media source is NOT Apple Music
if [ "$BUNDLE_ID" != "com.apple.Music" ]; then
  sketchybar --set $NAME drawing=on \
						 icon="$ICON_NOMEDIA" \
						 label="None Detected - Open Apple Music"
  exit 0
fi

# Do these only if Apple Music is running (i.e. it appears as the only Now Playing widget in the Control Center)
if [ "$PLAYBACK_RATE" -gt 0 ]; then
  sketchybar --set $NAME icon="$ICON_PLAY" \
                         label="$LABEL" \
                         drawing=on
else
  sketchybar --set $NAME icon="$ICON_PAUSE" \
                         label="$LABEL" \
                         drawing=on
fi
