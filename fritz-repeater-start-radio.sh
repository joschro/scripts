#!/bin/sh

test $# -lt 1 && {
	echo "No password provided. Exiting"
	exit
}
fritzPassword="$1"
fritzStation=1

test -f "$(dirname $0)/fritz-repeater.lastStation" && fritzStation="$(cat "$(dirname $0)/fritz-repeater.lastStation")"

test $# -gt 1 && fritzStation="$2"
echo "Station $fritzStation selected."

fritzURL="fritz.repeater"

plugIP=""
ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || {
        curl --silent http://$plugIP/cm?cmnd=Power%20OFF >/dev/null
        sleep 5
        curl --silent http://$plugIP/cm?cmnd=Power%20ON >/dev/null
        sleep 30
}

ping -q -c1 -w1 $fritzURL >/dev/null && echo "$fritzURL reachable" && curl http://fritz.repeater/cgi-bin/webcm  --data "configd:settings/NLR/PlayControl=$fritzStation" --data "login:command/password=$fritzPassword" --silent --connect-timeout 1 >/dev/null && echo "Turned on radio."

# Klassik Radio		1	http://stream.klassikradio.de/live/mp3-192/stream.klassikradio.de
# Antenne Düsseldorf	2	http://mp3.antennedus.c.nmdn.net/antennedus/livestream.mp3
# 1 LIVE		3	http://mp3.antennedus.c.nmdn.net/antennedus/livestream.mp3
# Fritz			4	http://www.fritz.de/live.m3u
# NEWS 89.4		5	http://stream.news894.de/444z5xy
# New York WNYC		6	http://wnycfm.streamguys.com/wnycfm.aac
# RTL France		7	icy://streaming.radio.rtl.fr:80/rtl-1-44-96
