#!/bin/sh

test $# -lt 1 && {
	echo "No password provided. Exiting"
	echo
	echo "Syntax: $0 <password> [<number-of-radiostation>] [<URL of FritzRepeater>]"
	exit
}
fritzPassword="$1"
shift

fritzStation=1
test -f "$(dirname $0)/fritz-repeater.lastStation" && fritzStation="$(cat "$(dirname $0)/fritz-repeater.lastStation")"
test $# -gt 0 && test $1 -ge 0 && fritzStation="$1" && shift
echo "Station $fritzStation selected."

test $# -gt 0 && fritzURL="$1"
ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || fritzURL="fritz.repeater"

tasmotaPlugIP=""
test -n "$tasmotaPlugIP" && ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || {
        curl --silent http://$tasmotaPlugIP/cm?cmnd=Power%20OFF >/dev/null
        sleep 5
        curl --silent http://$tasmotaPlugIP/cm?cmnd=Power%20ON >/dev/null
        sleep 30
}

ping -q -c1 -w1 $fritzURL >/dev/null && echo "$fritzURL reachable" && curl http://fritz.repeater/cgi-bin/webcm  --data "configd:settings/NLR/PlayControl=$fritzStation" --data "login:command/password=$fritzPassword" --silent --connect-timeout 1 >/dev/null && echo "Turned on radio."

# Klassik Radio		1	http://stream.klassikradio.de/live/mp3-192/stream.klassikradio.de
# Antenne Düsseldorf	2	http://mp3.antennedus.c.nmdn.net/antennedus/livestream.mp3
# 1 LIVE		3	http://wdr-1live-live.icecast.wdr.de/wdr/1live/live/mp3/128/stream.mp3
# Fritz			4	http://www.fritz.de/live.m3u
# NEWS 89.4		5	http://stream.news894.de/444z5xy
# New York WNYC		6	http://wnycfm.streamguys.com/wnycfm.aac
# RTL France		7	icy://streaming.radio.rtl.fr:80/rtl-1-44-96
