#!/bin/sh

test $# -lt 1 && { echo -e "Usage: $0 [--ip <IP>] [--token <API-Token>] <laden|auto|entlade_stop|entlade_ok>"; exit; }
sonnenBattIP="192.168.178.116"
sonnenBattAPIUrl="http://$sonnenBattIP:80/api/v2";
sonnenBattAPIToken="Auth-Token: $(cat ~/Projekte/github/private/api_keys/sonnenbatterie_api_key.txt)"
chargingPower=4600
ntfyTopic="$(cat ~/Projekte/github/private/ntfy_home.topic)"

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
                        sonnenBattAPIToken="$1";
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
			echo;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/charge/$chargingPower;
			echo;
			ntfy.sh "$ntfyTopic" "SonnenBatterie now charging with ${chargingPower}W: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge")";
			;;
	"auto")
			curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo;
			ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "SonnenBatterie now in auto mode: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge")";
			;;
	"entlade_stop")
			curl -X PUT -d EM_OperatingMode=1 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
                        echo;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/discharge/0;
			echo;
			ntfy.sh "$ntfyTopic" "Sonnenbatterie state changed" "SonnenBatterie discharging stopped: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge")";
			;;
	"entlade_ok")
			curl -X PUT -d EM_OperatingMode=2 --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/configurations;
			echo;
			curl -X POST --header "$sonnenBattAPIToken" -d "" $sonnenBattAPIUrl/setpoint/discharge/$chargingPower;
			echo;
			ntfy.sh "$ntfyTopic" "Sonnenbatterie state changed" "SonnenBatterie discharging allowed: $(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "RemainingCapacity_Wh\|OperatingMode\|discharge")";
			;;
	"status")
                        ntfy.sh "$ntfyTopic" "Sonnenbatterie status" "$(curl -s --header "$sonnenBattAPIToken" $sonnenBattAPIUrl/status | sed "s/,/\n/g" | grep -i "OperatingMode\|RemainingCapacity_Wh\|Pac_total_W\|dischargeNotAllowed\|GridFeedIn_W")";
                        ;;
	*)
			echo "Unknown command: $1";
			echo -e "Usage: $0 [--ip <IP>] [--token <API-Token>] <laden|auto|entlade_stop|entlade_ok>";
esac
echo
