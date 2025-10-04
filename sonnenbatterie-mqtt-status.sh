#!/bin/sh

test $# -lt 1 && {
        echo "Syntax: $0 <path-to-config>"
        exit
}

myApiKey="$(cat $1/api_keys/sonnenbatterie_api_key.txt)"
myMQTTBroker="$(cat $1/sho-mosquitto.host)"
myMQTTBrokerUser="$(cat $1/sho-mosquitto.user)"
myMQTTBrokerPwd="$(cat $1/sho-mosquitto.pwd)"
shift

mySonnenBatterieIP="192.168.178.116"
# 5%=1163Wh 100%=10642Wh
# 5%=1300Wh 100%=10642Wh
cap100=10642
cap5=1300

myTopic="sonnenbatterie/RemainingCapacity_kWh"
myMessage="$(curl -s --header "Auth-Token: $myApiKey" http://${mySonnenBatterieIP}:80/api/v2/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh"|sed "s/.*://g")"
echo "RemainingCapacity_Wh: $myMessage"
myMessage="$(echo "scale=3; $myMessage / 2" | bc -l)"
mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$(echo "scale=5; $myMessage / 1000" | bc -l)"
echo "Remaining Capacity (Wh): $myMessage of $cap100"

myTopic="sonnenbatterie/RemainingCapacity_%"
# f(x) = a * x + b
# a = (100-5) / ($cap100 - $cap5)
# b = 100 - a * $cap100
# f(x) = 0,0100221542357 * x - 6,65576537632
# f(x) = 0,0101691286662 * x - 8,2198672657
#myMessage="$(echo "scale=14; $myMessage / $cap100 * 100" | bc -l | xargs printf "%.0f\n")"
myMessage="$(echo "scale=14; 100 + ($myMessage - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")"
echo "Remaining Capacity (%): $myMessage"

mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$myMessage"

myTopics="Apparent_output BackupBuffer BatteryCharging BatteryDischarging Consumption_Avg Consumption_W Fac FlowConsumptionBattery FlowConsumptionGrid GridFeedIn_W OperatingMode Pac_total_W Production_W RSOC SystemStatus USOC Uac Ubat dischargeNotAllowed Sac1 Sac2 Sac3"
for I in $myTopics; do
	myTopic="sonnenbatterie/$I"
	myMessage="$(curl -s --header "Auth-Token: $myApiKey" http://${mySonnenBatterieIP}:80/api/v2/status | sed "s/,/\n/g" | grep -i "$I"|sed "s/.*://g")"
	mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$myMessage"
done
