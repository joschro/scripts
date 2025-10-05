#!/bin/sh

test $# -lt 1 && {
	echo "No password provided. Exiting"
	echo
	echo "Syntax: $0 <password> [<ip or name of Fritz!Box>]"
	exit
}
fritzPassword="$1"


fritzURL="fritz.box"
test $# -gt 1 && fritzURL="$2"

plugIP=""
#ping -q -c1 -w10 $fritzURL >/dev/null 2>&1 || {
##        curl --silent http://$plugIP/cm?cmnd=Power%20OFF >/dev/null
#        sleep 5
#        curl --silent http://$plugIP/cm?cmnd=Power%20ON >/dev/null
#        sleep 30
#}

#curl -k -m 5 --anyauth -u USER:PASSWORT http://ip-adresse:49000/upnp/control/deviceconfig -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:dslforum-org:service:DeviceConfig:1#Reboot" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:Reboot xmlns:u='urn:dslforum-org:service:DeviceConfig:1'></u:Reboot></s:Body></s:Envelope>" -s

#ping -q -c1 -w1 $fritzURL >/dev/null && echo "$fritzURL reachable" && curl http://fritz.repeater/cgi-bin/webcm  --data "configd:settings/NLR/PlayControl=$fritzStation" --data "login:command/password=$fritzPassword" --silent --connect-timeout 1 >/dev/null && echo "Turned on radio."

curl -v -k -m 5 --anyauth -u :$fritzPassword http://$fritzURL:49000/upnp/control/deviceconfig -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:dslforum-org:service:DeviceConfig:1#Reboot" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:Reboot xmlns:u='urn:dslforum-org:service:DeviceConfig:1'></u:Reboot></s:Body></s:Envelope>" -s
