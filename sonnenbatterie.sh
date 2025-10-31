#!/bin/sh

test $# -lt 2 && { echo -e "Usage: $0 <path-to-config> [-v] [--mqtt] [--nontfy] [--ip <IP>] [--token <API-Token>] [--duration <duration(minutes)>] [--until <percent>] <laden|auto|entlade_stop|entlade_ok|status>"; exit; }
configPath="$1"
sonnenBattIP="192.168.178.116"
sonnenBattAPIUrl="http://$sonnenBattIP:80/api/v2"
sonnenBattAPIToken="Auth-Token: $(cat $configPath/api_keys/sonnenbatterie_api_key.txt)"
chargingPower=4600
ntfyPath=~/bin
ntfyTopic="$(cat $configPath/ntfy_info.topic)"
myDuration=0
myLoadLimit=100
cap100=10642
percentLow=6
capLow=1198
shift

test $# -lt 1 && { echo "Parameter missing. Exiting."; exit;}
while [ $# -gt 1 ]; do
	case "$1" in
		"-v")
			shift;
			verbose=true;
                        ;;
		"--mqtt")
			shift;
			myMQTTBroker="$(cat $configPath/sho-mosquitto.host)"
			myMQTTBrokerUser="$(cat $configPath/sho-mosquitto.user)"
			myMQTTBrokerPwd="$(cat $configPath/sho-mosquitto.pwd)"
			doMqtt=true;
                        ;;
		"--nontfy")
			shift;
			noNtfy=true;
                        ;;
		"--ip")
			shift;
			test "$#" -lt 1 && { echo "Missing parameter, exiting."; exit;};
			sonnenBattIP="$1";
			sonnenBattAPIUrl="http://$sonnenBattIP:80/api/v2";
			shift;
                        ;;
		"--token")
                        shift;
                        test "$#" -lt 1 && { echo "Missing parameter, exiting."; exit;};
                        sonnenBattAPIToken="Auth-Token: $1";
			shift;
                        ;;
		"--duration")
                        shift;
                        test "$#" -lt 1 && { echo "Missing parameter, exiting."; exit;};
                        myDuration="$1";
                        shift;
                        ;;
		"--until")
                        shift;
                        test "$#" -lt 1 && { echo "Missing parameter, exiting."; exit;};
                        myLoadLimit="$1";
                        shift;
                        ;;
		*)
			echo "Using default params.";
			continue;
	esac
done

#echo "sonnenBattAPIUrl=$sonnenBattAPIUrl sonnenBattAPIToken=$sonnenBattAPIToken"

test $# -lt 1 && { echo "Parameter missing. Exiting."; exit;}
case $1 in
	"laden")
			curl -X PUT -d EM_OperatingMode=1 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo; sleep 1;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/charge/$chargingPower;
			echo; sleep 3;
			test $myDuration -eq 0 && test $myLoadLimit -eq 100 && {
				statusMessage="SonnenBatterie now charging with ${chargingPower}W: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%";
				test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
				test $noNtfy && echo -e "$statusMessage";
			}
			test $myDuration -gt 0 && {
				statusMessage="SonnenBatterie now charging with ${chargingPower}W for $myDuration minutes: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%"
				test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
				test $noNtfy && echo -e "$statusMessage";
				sleep $(echo "$myDuration * 60" | bc -l)
				curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations
	                        echo
			        statusMessage="SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%"
        	                test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
				test $noNtfy && echo -e "$statusMessage";
			};
			test $myLoadLimit -lt 100 && {
				statusMessage="SonnenBatterie now charging with ${chargingPower}W until ${myLoadLimit}%: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%"
				test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
				test $noNtfy && echo -e "$statusMessage";
				until [ $(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n") -ge $myLoadLimit ]; do
					sleep 60
				done
				curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations
	                        echo
			        statusMessage="SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%"
        	                test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
				test $noNtfy && echo -e "$statusMessage";
			};
			;;
	"auto")
			curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo; sleep 3;
		        statusMessage="SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%";
			test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
			test $noNtfy && echo -e "$statusMessage";
			;;
	"entlade_stop")
			curl -X PUT -d EM_OperatingMode=1 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
                        echo; sleep 1;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/discharge/0;
			echo; sleep 3;
		        statusMessage="SonnenBatterie discharging stopped: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%";
			test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie state changed" "$statusMessage";
			test $noNtfy && echo -e "$statusMessage";
			;;
	"entlade_ok")
			curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo; sleep 1;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/discharge/$chargingPower;
			echo; sleep 3;
		        statusMessage="SonnenBatterie discharging allowed: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%";
			test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie state changed" "$statusMessage";
			test $noNtfy && echo -e "$statusMessage";
			;;
	"status")
			statusMessage="$(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/\"//g;s/\}//g;s/,/\n/g") $(echo -e "\nRemainingCapacity_%:")$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%";
			test $verbose && { echo "---";echo -e "$statusMessage"; echo "---"; }
			test $doMqtt && {
				myTopic="sonnenbatterie/RemainingCapacity_kWh"
				mqttMessage="$(echo -e "$statusMessage" | grep -i "RemainingCapacity_Wh"|sed "s/.*://g")"
				mqttMessage="$(echo "scale=3; $mqttMessage / 2000" | bc -l)"
				mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$mqttMessage"
				myTopic="sonnenbatterie/RemainingCapacity_%"
				mqttMessage="$(echo "scale=14; 100 + ($mqttMessage * 1000 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")"
				mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$mqttMessage"
				myTopics="Apparent_output BackupBuffer BatteryCharging BatteryDischarging Consumption_Avg Consumption_W Fac FlowConsumptionBattery FlowConsumptionGrid GridFeedIn_W OperatingMode Pac_total_W Production_W RSOC SystemStatus USOC Uac Ubat dischargeNotAllowed Sac1 Sac2 Sac3"
				for I in $myTopics; do
					myTopic="sonnenbatterie/$I"
					mqttMessage="$(echo -e "$statusMessage" | grep -i "$I"|sed "s/.*://g")"
					mosquitto_pub -h $myMQTTBroker -u $myMQTTBrokerUser -P "$myMQTTBrokerPwd" -t "$myTopic" -m "$mqttMessage"
				done
			}
			statusMessage="$(echo -e "$statusMessage" | grep -i "OperatingMode\|RemainingCapacity\|Pac_total_W\|dischargeNotAllowed\|GridFeedIn_W")"
			test $noNtfy || ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$statusMessage";
			test $noNtfy && echo -e "$statusMessage";
                        #echo "$(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh")";
			#echo $(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * (100 - $percentLow) / ($cap100 - $capLow)" | bc -l | xargs printf "%.0f\n")%;
                        ;;
	*)
			echo "Unknown command: $1";
			echo -e "Usage: $0 <path-to-config> [--mqtt] [--nontfy] [--ip <IP>] [--token <API-Token>] [--duration <duration(minutes)>] [--until <percent>] <laden|auto|entlade_stop|entlade_ok|status>";
esac
echo
