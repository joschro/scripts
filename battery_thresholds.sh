#!/bin/sh

for J in /sys/class/power_supply/BAT*; do
	echo "$J ($(cat $J/model_name)):" 
	for I in $J/charge_*; do
		echo -ne "\t$I: "
		cat $I
	done
done
