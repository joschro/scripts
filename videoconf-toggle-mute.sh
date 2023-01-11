#!/bin/sh

xdotool windowactivate "$(xdotool search --name "Meet -" | head -1)" key Ctrl+d || wtype -M ctrl d -m ctrl
xdotool windowactivate "$(xdotool search --name "Zoom" | head -1)" key Alt+a || wtype -M alt a -m alt
xdotool windowactivate "$(xdotool search --name "BigBlueButton -" | head -1)" key Alt+M || wtype -M alt M -m alt
