#!/bin/sh

for busyLight in 192.168.178.87 10.93.124.8; do
	ping -c1 -w1 $busyLight >/dev/null 2>&1 && curl http://$busyLight/cm?cmnd=Power && echo
done
