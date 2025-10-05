#!/bin/sh

test $# -lt 3 && {
	echo "Syntax: $0 <path-to-config> <topic> <tibber-bridge-password>"
        exit
}

myConfigPath="$1"
myApiKey="$(cat $myConfigPath/api_keys/sonnenbatterie_api_key.txt)"
myMQTTBroker="$(cat $myConfigPath/sho-mosquitto.host)"
myMQTTBrokerUser="$(cat $myConfigPath/sho-mosquitto.user)"
myMQTTBrokerPwd="$(cat $myConfigPath/sho-mosquitto.pwd)"
shift

myTopic="$1"
shift

myMessage="~/bin/pysmlparser.py not available."
test -f ~/bin/pysmlparser.py && myMessage="$(curl --output - -s -u admin:"$1" http://192.168.178.214/data.json?node_id=1 | python3.9 ~/bin/pysmlparser.py | grep Total)"

shift
test "$1" = "ntfy" && ~/bin/ntfy.sh "$myTopic" "Stromzählerstände Tibber Pulse" "$myMessage"

echo $myMessage | grep "triggered" >/dev/null && exit

my180="$(echo $myMessage | sed "s/.*-> \(.*\)Wh (Zählerstand Bezug.*/\1/g")"
my180="$(echo "scale=3; $my180 / 1000" | bc -l)"
myTopic="pulse/180_kWh"
test "$(echo $my180 | sed "s/\..*//")" -gt 0 && mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$my180"

my280="$(echo $myMessage | sed "s/.*-> \(.*\)Wh (Zählerstand Einsp.*/\1/g")"
my280="$(echo "scale=3; $my280 / 1000" | bc -l)"
myTopic="pulse/280_kWh"
test "$(echo $my280 | sed "s/\..*//")" -gt 0 && mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$my280"
echo "180: $my180 / 280: $my280"
