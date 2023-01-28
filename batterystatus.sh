#!/bin/sh

for I in /sys/class/power_supply/BAT*; do
	echo "$(echo "( 100 * $(cat $I/energy_now) / $(cat $I/energy_full_design) )" | bc)%"
done
