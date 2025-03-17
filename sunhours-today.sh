#!/bin/bash

LAT="$(cat ~/Projekte/github/private/location.lat)"
LON="$(cat ~/Projekte/github/private/location.lon)"
TOPIC="$(cat ~/Projekte/github/private/ntfy_info.topic)"


# Wetterdaten abrufen
RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

# Sonnenstunden für morgen extrahieren
SUN_MINS=$(echo $RESPONSE | jq '.daily.sunshine_duration[0]')
SUN_HOURS="$(echo $SUN_MINS / 3600 | bc)"

# Nachricht an ntfy.sh senden
MESSAGE="Sonnenstunden heute: $SUN_HOURS Stunden ☀️"
echo "$MESSAGE"

