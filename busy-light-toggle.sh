#!/bin/sh

for busyLight in 192.168.178.87 10.93.124.153; do
	ping -c1 -w1 $busyLight >/dev/null 2>&1 && curl --silent http://$busyLight/cm?cmnd=Power%20TOGGLE >/dev/null
done
