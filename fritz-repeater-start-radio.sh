#!/bin/sh

test $# -lt 1 && {
	echo "No password provided. Exiting"
	exit
}
fritzPassword="$1"
curl http://fritz.repeater/cgi-bin/webcm  --data "configd:settings/NLR/PlayControl=1" --data "login:command/password=$fritzPassword" --silent --connect-timeout 1 >/dev/null
