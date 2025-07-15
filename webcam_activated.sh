#!/bin/sh

# home
ping -c1 -w1 192.168.178.1 >/dev/null && {
  # Elgato Keylights
  elgato-key-light-an.sh
}

# Tasmota busy lights
busy-lights.sh on

# office
MACs="A0:20:A6:06:32:A3"
for busylight_ip in $(~/bin/ip-of-mac.sh "$MACs"); do
  # Tasmota busy lights
  busy-lights.sh on $busylight_ip
done

logger "Videoconf lights on."

webcam-defaults.sh
