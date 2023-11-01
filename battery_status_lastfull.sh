#!/bin/sh

for I in /sys/class/power_supply/BAT*; do
	test -f $I/charge_full && battCap="$(echo "100 * $(cat $I/charge_now) / $(cat $I/charge_full)" | bc)"
	test -f $I/energy_full && battCap="$(echo "100 * $(cat $I/energy_now) / $(cat $I/energy_full)" | bc)"
	echo -n "Capacity currently against last full $I: "
	echo -n "$battCap%"
	echo " - $(cat $I/status) - Power connected: $(cat /sys/class/power_supply/AC/online)"
done
