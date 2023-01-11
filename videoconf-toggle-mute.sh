#!/bin/sh

xdotool windowactivate "$(xdotool search --name "Meet -" | head -1)" key Ctrl+d
xdotool windowactivate "$(xdotool search --name "Zoom" | head -1)" key Alt+a
xdotool windowactivate "$(xdotool search --name "BigBlueButton -" | head -1)" key Alt+M
