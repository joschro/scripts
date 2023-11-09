#!/bin/sh

for J in /sys/class/power_supply/BAT*; do
	echo "$J ($(cat $J/model_name), $(echo "$(cat $J/energy_full_design) / 1000000" | bc)Wh):" 
	for I in $J/charge_*; do
		echo -ne "\t$I: "
		cat $I
	done
done
