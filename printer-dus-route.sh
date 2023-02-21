#!/bin/sh

subnet="10.93.124.0"
router="10.0.2.2"
echo "ip r | grep "$subnet" || ip r add $subnet/24 via $router"
ip r | grep "$subnet" || ip r add $subnet/24 via $router && echo "Route $subnet/24 via $router set: $(ip route sh | grep $subnet)"
