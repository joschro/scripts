#!/bin/sh

elgato_ip="192.168.178.23"
python3 ~/bin/elgato-key-light.py -i "$elgato_ip" -b 100 -c 4000
elgato_ip="192.168.178.168"
python3 ~/bin/elgato-key-light.py -i "$elgato_ip" -b 10 -c 4000
