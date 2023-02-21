#!/bin/sh

# home
ping -c1 -w1 192.168.178.1 >/dev/null && {
  elgato_ip=192.168.178.23
  #led_ip=192.168.178.125
  busylight_ip=192.168.178.87
  # Elgato Keylights
  ping -c1 -w1 $elgato_ip >/dev/null 2>&1 && elgato-key-light-toggle.sh >/dev/null
  # Tasmota busy lights
  #ping -c1 -w1 $led_ip >/dev/null 2>&1 && curl http://$led_ip/cm?cmnd=Power%20TOGGLE >/dev/null
  ping -c1 -w1 $busylight_ip >/dev/null 2>&1 && curl http://$busylight_ip/cm?cmnd=Power%20TOGGLE >/dev/null
}

# office
ping -c1 -w1 10.93.124.1 >/dev/null && {
  busylight_ip=10.93.124.6
  # Tasmota busy lights
  ping -c1 -w1 $busylight_ip >/dev/null 2>&1 && curl http://$busylight_ip/cm?cmnd=Power%20TOGGLE >/dev/null
}
