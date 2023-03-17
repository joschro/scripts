#!/bin/sh

elgato_ip="192.168.178.23 192.168.178.168"

# defaults
elgato_options="-b 70 -c 4000"

test $# -ge 1 && elgato_options="$*"

for I in $elgato_ip; do
       python3 ~/bin/elgato-key-light.py -i $I $elgato_options &
done
echo
