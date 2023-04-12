#!/bin/sh

xdotool windowactivate "$(xdotool search --name "Meet " | head -1)" key Ctrl+Alt+h || wtype -M ctrl -M alt h -m ctrl -m alt
xdotool windowactivate "$(xdotool search --name "BigBlueButton -" | head -1)" key Alt+r || wtype -M alt r -m alt
