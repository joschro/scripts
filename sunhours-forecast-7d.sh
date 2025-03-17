#!/bin/bash

LAT="$(cat ~/Projekte/github/private/location.lat)"
LON="$(cat ~/Projekte/github/private/location.lon)"
TOPIC="$(cat ~/Projekte/github/private/ntfy_info.topic)"


# Wetterdaten abrufen
RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

for I in {0..6}; do
	# Sonnenstunden für extrahieren
	SUN_DAY=$(echo $RESPONSE | jq ".daily.time[$I]")
	SUN_MINS=$(echo $RESPONSE | jq ".daily.sunshine_duration[$I]")
	SUN_HOURS="$(echo $SUN_MINS / 3600 | bc)"

	MESSAGE="Sonnenstunden $SUN_DAY: $SUN_HOURS Stunden ☀️"
	# Nachricht an ntfy.sh senden
	#curl -s -d "$MESSAGE" "https://ntfy.sh/$TOPIC" >/dev/null
	echo "$MESSAGE"
done
