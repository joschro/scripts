#!/bin/sh

xdotool windowactivate "$(xdotool search --name "Meet -" | head -1)" key Ctrl+Alt+h
xdotool windowactivate "$(xdotool search --name "BigBlueButton -" | head -1)" key Alt+r
