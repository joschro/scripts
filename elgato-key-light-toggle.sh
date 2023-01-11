#!/bin/sh

if [ "$(python3 ~/bin/elgato-key-light-status.py)" = 1 ]; then
	echo "Keylight is on, toggle off"
        python3 ~/bin/elgato-key-light.py -0
else
	echo "Keylight is off, toggle on"
	python3 ~/bin/elgato-key-light.py -1
fi
