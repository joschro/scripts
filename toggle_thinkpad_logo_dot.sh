#!/bin/sh

logoDot="/sys/class/leds/tpacpi::lid_logo_dot/brightness"
echo $(cat "$logoDot")
if [ "$(cat "$logoDot")" -eq 0 ]; then
	echo 1 | sudo tee /sys/class/leds/tpacpi\:\:lid_logo_dot/brightness
else
	echo 0 | sudo tee /sys/class/leds/tpacpi\:\:lid_logo_dot/brightness
fi
