#!/bin/bash

LAT="$(cat ~/Projekte/github/private/location.lat)"
LON="$(cat ~/Projekte/github/private/location.lon)"
TOPIC="$(cat ~/Projekte/github/private/ntfy_info.topic)"
DAY="$1"

case $DAY in 
	"heute")
		dayNumber=0;
		;;
	"morgen")
		dayNumber=1;
		;;
	"übermorgen")
		dayNumber=2;
		;;
	*)
		exit
esac

# Wetterdaten abrufen
RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

# Sonnenstunden für morgen extrahieren
SUN_MINS=$(echo $RESPONSE | jq ".daily.sunshine_duration[$dayNumber]")
SUN_HOURS="$(echo $SUN_MINS / 3600 | bc)"

# Nachricht an ntfy.sh senden
<<<<<<< HEAD
MESSAGE="Sonnenstunden $DAY: $SUN_HOURS Stunden ☀️"
curl -d "$MESSAGE" "https://ntfy.sh/$TOPIC"
=======
MESSAGE="Sonnenstunden morgen: $SUN_HOURS Stunden ☀️"
curl -s -d "$MESSAGE" "https://ntfy.sh/$TOPIC" >/dev/null
>>>>>>> 32688d9b5c5d6f208e530a5b6f64dd633b5247e6

