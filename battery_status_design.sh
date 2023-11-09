#!/bin/sh

for I in /sys/class/power_supply/BAT*; do
	test -f $I/charge_full && battCap="$(echo "100 * $(cat $I/charge_full) / $(cat $I/charge_full_design)" | bc)"
	test -f $I/energy_full && battCap="$(echo "100 * $(cat $I/energy_full) / $(cat $I/energy_full_design)" | bc)"
	echo -n "Capacity last full against design $I ($(cat $I/model_name), $(echo "$(cat $I/energy_full_design) / 1000000" | bc)Wh): "
	echo -n "$battCap%"
	echo " - $(cat $I/status) - Power connected: $(cat /sys/class/power_supply/AC/online)"
done
