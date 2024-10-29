#!/bin/sh

MACs="A0:20:A6:06:32:A3"
for busyLight in 192.168.178.87 $(~/bin/ip-of-mac.sh "$MACs"); do
	ping -c1 -w1 $busyLight >/dev/null 2>&1 && curl http://$busyLight/cm?cmnd=Power && echo
done
