#!/bin/sh

ping -c1 -w1 192.168.178.23 >/dev/null 2>&1 && {
if [ "$(python3 ~/bin/elgato-key-light-status.py)" = 1 ]; then
	echo "Keylight is on, toggle off"
        python3 ~/bin/elgato-key-light.py -0
else
	echo "Keylight is off, toggle on"
	python3 ~/bin/elgato-key-light.py -1
fi
}

ping -c1 -w1 10.93.124.8 >/dev/null 2>&1 && curl http://10.93.124.8/cm?cmnd=Power%20TOGGLE >/dev/null
