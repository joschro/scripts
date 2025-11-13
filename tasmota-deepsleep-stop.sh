#!/bin/sh

test $# -lt 2 && { echo -e "Usage: $0 <path-to-config> <device-name> [-r]"; exit; }
configPath="$1"
myMQTTBroker="$(cat $configPath/sho-mosquitto.host)"
myMQTTBrokerUser="$(cat $configPath/sho-mosquitto.user)"
myMQTTBrokerPwd="$(cat $configPath/sho-mosquitto.pwd)"
shift

myTopic="cmnd/$1/DeepsleepTime"
mqttMessage="0"
shift

# set retained message to set DeepSleepTime to 0
test $# -eq 0 && mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -r -m "$mqttMessage"
# remove retained message
test $# -gt 0 && test "$1" = "-r" && mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -r -n
