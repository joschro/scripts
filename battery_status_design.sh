#!/bin/sh

for I in /sys/class/power_supply/BAT*; do
	battCap="$(echo "100 * $(cat $I/energy_full) / $(cat $I/energy_full_design)" | bc)"
	echo -n "Capacity last full against design $I: "
	echo -n "$battCap%"
	echo " - $(cat $I/status)"
done
