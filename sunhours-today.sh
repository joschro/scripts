#!/bin/bash

test $# -lt 1 && {
        echo "Syntax: $0 <path-to-config> [-ntfy]"
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

# Wetterdaten abrufen
RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

# Sonnenstunden für morgen extrahieren
SUN_MINS=$(echo $RESPONSE | jq '.daily.sunshine_duration[0]')
SUN_HOURS="$(echo $SUN_MINS / 3600 | bc)"

# Nachricht an ntfy.sh senden
MESSAGE="Sonnenstunden heute: $SUN_HOURS"
test $SUN_HOURS -gt 0 && MESSAGE="$MESSAGE ☀️"
echo "$MESSAGE"
test $noNtfy || curl -s -d "$MESSAGE" "https://ntfy.sh/$TOPIC" >/dev/null
