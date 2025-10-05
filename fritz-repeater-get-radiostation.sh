#!/bin/sh

test $# -lt 1 && {
        echo "No password provided. Exiting"
	echo
	echo "Syntax: $0 <password> [<URL of FritzRepeater>]"
        exit
}
fritzPassword="$1"
shift

test $# -gt 0 && fritzURL="$1"
ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || fritzURL="fritz.repeater"

fritzStation=1
fritzStationDir="$(dirname $0)"
fritzStationDir="~/"

tasmotaPlugIP=""
test -n "$tasmotaPlugIP" && ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || {
        curl --silent http://$tasmotaPlugIP/cm?cmnd=Power%20OFF >/dev/null
        sleep 5
        curl --silent http://$tasmotaPlugIP/cm?cmnd=Power%20ON >/dev/null
        sleep 30
}

#fritzStation="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl "http://:${fritzPassword}@$fritzURL/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/NLR/PlayStatus" --silent --connect-timeout 1)"
fritzStation="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl -u ":$fritzPassword" "http://$fritzURL/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/NLR/PlayStatus" --silent --connect-timeout 1 2>/dev/null)"
[[ -n "$fritzStation" ]] && [[ $fritzStation -gt 0 ]] || exit
echo "Station $fritzStation selected."

let station=${fritzStation}-1
#fritzStationName="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl "http://:${fritzPassword}@$fritzURL/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/WEBRADIO${station}/Name" --silent --connect-timeout 1)"
fritzStationName="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl -u ":$fritzPassword" "http://$fritzURL/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/WEBRADIO${station}/Name" --silent --connect-timeout 1 2>/dev/null)"
echo "Station $fritzStationName selected."

test -f "$fritzStationDir/fritz-repeater.lastStation" && test $(cat "$fritzStationDir/fritz-repeater.lastStation") -eq $fritzStation && exit
echo "$fritzStation" > "$fritzStationDir/fritz-repeater.lastStation"
