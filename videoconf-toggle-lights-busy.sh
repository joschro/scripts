#!/bin/sh

# home
ping -c1 -w1 192.168.178.1 >/dev/null && {
  elgato_ip=192.168.178.23
  #led_ip=192.168.178.125
  busylight_ip=192.168.178.87
  # Elgato Keylights
  ping -c1 -w1 $elgato_ip >/dev/null 2>&1 && elgato-key-light-toggle.sh >/dev/null && sleep 1
  # Tasmota busy lights
  #ping -c1 -w1 $led_ip >/dev/null 2>&1 && curl --silent http://$led_ip/cm?cmnd=Power%20TOGGLE >/dev/null
  keyligthOn=no
  elgato-key-light-status.sh | grep "isOn': 1" >/dev/null && keyligthOn=yes
  if [ "$keyligthOn" = "yes" ]; then
	  logger "Keylight toggled on."
	  while [ -n "$(busy-light-status.sh 2>/dev/null | grep OFF)" ]; do
		  logger "Busy light is off. Toggle."
		  ping -c1 -w1 $busylight_ip >/dev/null 2>&1 && curl --silent http://$busylight_ip/cm?cmnd=Power%20TOGGLE >/dev/null
		  sleep 2
	  done
  else
	  logger "Keylight toggled off."
	  while [ -n "$(busy-light-status.sh 2>/dev/null | grep ON)" ]; do
		  logger "Busy light is on. Toggle."
		  ping -c1 -w1 $busylight_ip >/dev/null 2>&1 && curl --silent http://$busylight_ip/cm?cmnd=Power%20TOGGLE >/dev/null
		  sleep 2
	  done
  fi
}

# office
MACs="A0:20:A6:06:32:A3"
for busylight_ip in $(~/bin/ip-of-mac.sh "$MACs"); do
  # Tasmota busy lights
  ping -c1 -w1 $busylight_ip >/dev/null 2>&1 && curl --silent http://$busylight_ip/cm?cmnd=Power%20TOGGLE >/dev/null
done

logger "Videoconf lights toggled."
