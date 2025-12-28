#!/bin/sh

test $# -lt 2 && {
	echo "Syntax: $0 <topic> <hichi ip>"
        exit
}

myTopic="$1"
shift
ntfyPath="~/bin"
myMessage="$(echo -e "total_in: $(curl -s "http://$1/cm?cmnd=status%2010" | jq '.StatusSNS."".total_in')\ntotal_out: $(curl -s "http://$1/cm?cmnd=status%2010" | jq '.StatusSNS."".total_out')")"

sh $ntfyPath/ntfy.sh "$myTopic" "Stromzählerstände Hichi" "$myMessage"
