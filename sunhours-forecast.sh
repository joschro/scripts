#!/bin/bash

test $# -lt 2 && {
        echo "Syntax: $0 <path-to-config> [-nontfy] <today|tomorrow|week|next6d>"
        exit
}

myConfigPath="$1"
shift

test "$1" = "-nontfy" && {
	noNtfy=true
	shift
}

LAT="$(cat $myConfigPath/location.lat)"
LON="$(cat $myConfigPath/location.lon)"
TOPIC="$(cat $myConfigPath/ntfy_info.topic)"
DAY="$1"

case $DAY in 
	"today"|"heute")
		dayNumber=0;
		;;
	"tomorrow"|"morgen")
		dayNumber=1;
		;;
	"aftertomorrow"|"übermorgen")
		dayNumber=2;
		;;
	"week"|"woche")
		dayNumber="$(echo {0..6})";
		;;
	"next6d"|"nächste6tage")
		dayNumber="$(echo {1..6})";
		;;
	*)
		echo "Error: unknown parameter \"$DAY\". Exiting."
        	echo
		echo "Syntax: $0 <path-to-config> [-nontfy] <today|tomorrow|week|next6d>"
		exit
esac

# Wetterdaten abrufen
RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

for I in $dayNumber; do
        # Sonnenstunden für extrahieren
        SUN_DAY=$(echo $RESPONSE | jq ".daily.time[$I]")
        SUN_MINS=$(echo $RESPONSE | jq ".daily.sunshine_duration[$I]")
        SUN_HOURS="$(echo $SUN_MINS / 3600 | bc)"

	MESSAGE="$(echo -e "$MESSAGE\nSonnenstunden $SUN_DAY: $SUN_HOURS")"
	test $SUN_HOURS -gt 0 && MESSAGE="$MESSAGE ☀️"
done
# Nachricht an ntfy.sh senden
test $noNtfy || curl -s -d "$MESSAGE" "https://ntfy.sh/$TOPIC" >/dev/null
echo "$MESSAGE"
