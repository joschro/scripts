#!/bin/sh

test $# -lt 1 && {
	echo "No password provided. Exiting"
	exit
}
fritzPassword="$1"

test $# -gt 1 && fritzStation="$2" && echo "Station $fritzStation selected."

fritzURL="fritz.repeater"
ping -q -c1 -w1 $fritzURL >/dev/null && echo "$fritzURL reachable" && curl http://fritz.repeater/cgi-bin/webcm  --data "configd:settings/NLR/PlayControl=$fritzStation" --data "login:command/password=$fritzPassword" --silent --connect-timeout 1 >/dev/null && echo "Turned on radio."
