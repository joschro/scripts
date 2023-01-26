#!/bin/sh

elgato_ip=192.168.178.23

test $# -ge 1 && elgato_ip=$1

python3 ~/bin/elgato-key-light.py -i $elgato_ip  -b 15 -c 3600
