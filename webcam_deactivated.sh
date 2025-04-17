#!/bin/sh

# home
ping -c1 -w1 192.168.178.1 >/dev/null && {
  # Elgato Keylights
  elgato-key-light-aus.sh
}

# Tasmota busy lights
busy-lights.sh off

# office
MACs="A0:20:A6:06:32:A3"
for busylight_ip in $(~/bin/ip-of-mac.sh "$MACs"); do
  # Tasmota busy lights
  busy-lights.sh off $busylight_ip
done

logger "Videoconf lights off."
