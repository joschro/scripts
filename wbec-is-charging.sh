#!/bin/sh

WBEC_IP="192.168.178.102"

while [ $# -gt 1 ]; do
	case "$1" in
		"-v")
			echo "Command issued: $0 $*";
			shift;
			verbose=true;
                        ;;
		"--wbec")
			shift;
			test "$#" -lt 1 && { echo "Missing parameter, exiting."; exit;};
			WBEC_IP="$1";
			shift;
			;;
		*)
			echo "Using default params.";
			continue;
	esac
done

statusMessage="triggered"
statusMessage="$(ping -c 3 -w 20 $WBEC_IP >/dev/null && curl -s "http://$WBEC_IP/json" | jq '.box[] | .power')"
until [[ "$statusMessage" != "triggered" ]]; do
	sleep 10
        statusMessage="$(ping -c 3 -w 20 $WBEC_IP >/dev/null && curl -s "http://$WBEC_IP/json" | jq '.box[] | .power')"
done
statusMessage=$(tr -dc '0-9' <<< "$statusMessage")

test $verbose && echo "Charging state: /${statusMessage}/"

[[ ${statusMessage} == "00" ]] && exit 1 || exit 0

#[ "$p1" = "0" ] && [ "$p2" = "0" ] && exit 1 || exit 0

#curl -s "http://$WBEC_IP/json" | jq '(.box[0].power | tonumber) == 0 and (.box[1].power | tonumber) == 0' >/dev/null || exit 1
#curl -s "http://$WBEC_IP/json" | jq '(.box[0].power | tonumber) == 0'
