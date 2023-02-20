#!/bin/sh

elgato_ip="192.168.178.23 192.168.178.168"

test $# -ge 1 && elgato_ip="$*"

for I in $elgato_ip; do
	python3 ~/bin/elgato-key-light.py -i $I  -b 15 -c 3600
done
