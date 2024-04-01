#!/bin/sh

test $# -lt 1 && {
        echo "No password provided. Exiting"
        exit
}
fritzPassword="$1"
fritzStation=1

test $# -gt 1 && fritzStation="$2"

fritzURL="fritz.repeater"
plugIP=""

ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || {
        curl --silent http://$plugIP/cm?cmnd=Power%20OFF >/dev/null
        sleep 5
        curl --silent http://$plugIP/cm?cmnd=Power%20ON >/dev/null
        sleep 30
}

#fritzStation="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl -u ":${fritzPassword}" 'http://fritz.repeater/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/NLR/PlayStatus' --silent --connect-timeout 1)"
#echo "Station $fritzStation selected."
#let station=${fritzStation}-1
#fritzStationName="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl -u ":${fritzPassword}" "http://fritz.repeater/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/WEBRADIO${station}/Name" --silent --connect-timeout 1)"
fritzStation="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl "http://:${fritzPassword}@fritz.repeater/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/NLR/PlayStatus" --silent --connect-timeout 1)"
echo "Station $fritzStation selected."
let station=${fritzStation}-1
fritzStationName="$(ping -q -c1 -w1 $fritzURL >/dev/null && curl "http://:${fritzPassword}@fritz.repeater/cgi-bin/webcm?getpage=../html/query.txt&var:n%5B1%5D=configd:settings/WEBRADIO${station}/Name" --silent --connect-timeout 1)"
echo "Station $fritzStationName selected."
