#!/bin/sh

echo;echo "Temperatures"
paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'

echo;echo -n "CPU turbo deactived?: "; cat /sys/devices/system/cpu/intel_pstate/no_turbo
test $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) -eq 0 && {
	echo -n "Do you want to deactivate cpu turbo mode [y|n]? "; read ANSW
	test "$ANSW" = "y" && sudo sh -c "echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo"
	echo -n "CPU turbo deactived?: "; cat /sys/devices/system/cpu/intel_pstate/no_turbo
}

echo;echo "Battery"
battery_status.sh
