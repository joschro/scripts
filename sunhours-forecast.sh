#!/bin/bash

LAT="51.30881647251574"
LON="6.683780887906319"
TOPIC="Wasserstr56Info"

# Wetterdaten abrufen
RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

# Sonnenstunden für morgen extrahieren
SUN_MINS=$(echo $RESPONSE | jq '.daily.sunshine_duration[1]')
SUN_HOURS="$(echo $SUN_MINS / 3600 | bc)"

# Nachricht an ntfy.sh senden
MESSAGE="Sonnenstunden morgen: $SUN_HOURS Minuten ☀️"
curl -d "$MESSAGE" "https://ntfy.sh/$TOPIC"

