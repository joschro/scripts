#!/bin/sh

for I in /sys/class/power_supply/BAT*; do
	echo -n "Capacity currently against last full $I ($(cat $I/model_name), $(echo "$(cat $I/*_full_design) / 1000000" | bc)Wh): "
	test -f $I/charge_now && echo -n "$(echo "( 100 * $(cat $I/charge_now) / $(cat $I/charge_full) )" | bc)%"
	test -f $I/energy_now && echo -n "$(echo "( 100 * $(cat $I/energy_now) / $(cat $I/energy_full) )" | bc)%"
	echo " - $(cat $I/status) ($(cat $I/charge_control_start_threshold)%<->$(cat $I/charge_control_end_threshold)%) - Power connected: $(cat /sys/class/power_supply/A*/online)"
done
