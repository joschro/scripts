#!/bin/sh

ip r | grep "10.4.20.0" || ip r add 10.4.20.0/24 via 10.4.110.1 && echo "Route 10.4.20.0/24 via 10.4.110.1 set: $(ip route sh | grep 10.4.20.0)"
