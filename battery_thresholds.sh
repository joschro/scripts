#!/bin/sh

for I in /sys/class/power_supply/BAT0/charge_*; do
       echo -n "$I: "
       cat $I
done
