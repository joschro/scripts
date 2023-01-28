#!/bin/sh

battCap="$(echo "100 * $(cat /sys/class/power_supply/BAT0/energy_full) / $(cat /sys/class/power_supply/BAT0/energy_full_design)" | bc)"
echo -n "$battCap%"
echo " - $(cat /sys/class/power_supply/BAT0/status)"
