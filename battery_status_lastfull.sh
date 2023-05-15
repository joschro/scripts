#!/bin/sh

for I in /sys/class/power_supply/BAT*; do
	battCap="$(echo "100 * $(cat $I/energy_now) / $(cat $I/energy_full)" | bc)"
	echo -n "Capacity currently against last full $I: "
	echo -n "$battCap%"
	echo " - $(cat $I/status) - Power connected: $(cat /sys/class/power_supply/AC/online)"
done
