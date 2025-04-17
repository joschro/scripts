#!/bin/sh

# Tasmota based lights only

test $# -lt 1 && {
	echo "Syntax: $0 <on|off|toggle|status> [ip1 ip2 ...]"
	exit
}

case $1 in
	"on"|"ON"|"1")
		cmnd="Power%20ON";
		;;
	"off"|"OFF"|"0")
		cmnd="Power%20OFF";
		;;
	"toggle"|"TOGGLE"|"2")
		cmnd="Power%20TOGGLE";
		;;
	"status"|"Status"|"-q")
		cmnd="Power";
		;;
	"help"|"--help"|"-h")
		echo "Syntax: $0 <on|off|toggle|status> <ip> [ip ...]";
		exit;
esac

shift

busyLights="192.168.178.87"
test $# -gt 0 && busyLights="$*"

echo "Set state of $busyLights to $cmnd"

for busyLight in $busyLights; do
	ping -c1 -w1 $busyLight >/dev/null 2>&1 && curl --silent http://$busyLight/cm?cmnd=${cmnd} >/dev/null
done
