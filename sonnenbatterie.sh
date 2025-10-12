#!/bin/sh

test $# -lt 2 && { echo -e "Usage: $0 <path-to-config> [--ip <IP>] [--token <API-Token>] [--duration <duration(minutes)>] [--until <percent>] <laden|auto|entlade_stop|entlade_ok|status>"; exit; }
sonnenBattIP="192.168.178.116"
sonnenBattAPIUrl="http://$sonnenBattIP:80/api/v2"
sonnenBattAPIToken="Auth-Token: $(cat $1/api_keys/sonnenbatterie_api_key.txt)"
chargingPower=4600
ntfyPath=~/bin
ntfyTopic="$(cat $1/ntfy_info.topic)"
myDuration=0
myLoadLimit=100
cap100=10642
cap5=1347
shift

test $# -lt 1 && { echo "Parameter missing. Exiting."; exit;}
while [ $# -gt 1 ]; do
	case "$1" in
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

echo "sonnenBattAPIUrl=$sonnenBattAPIUrl sonnenBattAPIToken=$sonnenBattAPIToken"

test $# -lt 1 && { echo "Parameter missing. Exiting."; exit;}
case $1 in
	"laden")
			curl -X PUT -d EM_OperatingMode=1 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo; sleep 1;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/charge/$chargingPower;
			echo; sleep 3;
			test $myDuration -eq 0 && test $myLoadLimit -eq 100 && ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now charging with ${chargingPower}W: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%";
			test $myDuration -gt 0 && {
				${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now charging with ${chargingPower}W for $myDuration minutes: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%"
				sleep $(echo "$myDuration * 60" | bc -l)
				curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations
	                        echo
        	                ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%"
			};
			test $myLoadLimit -lt 100 && {
				${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now charging with ${chargingPower}W until ${myLoadLimit}%: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%"
				until [ $(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n") -ge $myLoadLimit ]; do
					sleep 60
				done
				curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations
	                        echo
        	                ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%"
			};
			;;
	"auto")
			curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo; sleep 3;
			${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%";
			;;
	"entlade_stop")
			curl -X PUT -d EM_OperatingMode=1 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
                        echo; sleep 1;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/discharge/0;
			echo; sleep 3;
			${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie state changed" "SonnenBatterie discharging stopped: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%";
			;;
	"entlade_ok")
			curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo; sleep 1;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/discharge/$chargingPower;
			echo; sleep 3;
			${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie state changed" "SonnenBatterie discharging allowed: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%";
			;;
	"status")
                        ${ntfyPath}/ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "OperatingMode\|RemainingCapacity_Wh\|Pac_total_W\|dischargeNotAllowed\|GridFeedIn_W") RemainingCapacity_%:$(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%";
                        #echo "$(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh")";
			#echo $(echo "scale=14; 100 + ($(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh" | sed "s/\"RemainingCapacity_Wh\"://g") / 2 - $cap100) * 95 / ($cap100 - $cap5)" | bc -l | xargs printf "%.0f\n")%;
                        ;;
	*)
			echo "Unknown command: $1";
			echo -e "Usage: $0 <path-to-config> [--ip <IP>] [--token <API-Token>] [--duration <duration(minutes)>] [--until <percent>] <laden|auto|entlade_stop|entlade_ok|status>";
esac
echo
