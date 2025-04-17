#!/bin/bash

# Setze deinen API-Key hier
API_KEY="$(~/Projekte/github/private/entsoe-apikey.txt)"

# Setze die Marktzonen-ID für dein Land (z.B. "10YDE-VE-------2" für Deutschland)
MARKET_AREA="10YDE-VE-------2"
#MARKET_AREA="10YAT-APG------L"

# Datum für morgen im Format YYYYMMDD
TOMORROW=$(date -d "tomorrow" +"%Y%m%d")
TODAY=$(date -d "today" +"%Y%m%d")

# URL zur Abfrage der Day-Ahead-Preise
URL="https://web-api.tp.entsoe.eu/api?securityToken=$API_KEY&documentType=A44&in_Domain=$MARKET_AREA&out_Domain=$MARKET_AREA&periodStart=${TODAY}0000&periodEnd=${TOMORROW}2300"
URL="https://web-api.tp.entsoe.eu/api?securityToken=$API_KEY&documentType=A44&out_Domain=$MARKET_AREA&in_Domain=$MARKET_AREA&periodStart=${TODAY}0000&periodEnd=${TOMORROW}2300"

# API-Abfrage durchführen
RESPONSE=$(curl -s "$URL")

# Prüfen, ob eine Antwort erhalten wurde
if [[ -z "$RESPONSE" ]]; then
    echo "Fehler: Keine Daten empfangen."
    exit 1
fi
echo "$URL";echo "$RESPONSE"
# Preise aus der XML-Antwort extrahieren (erfordert `xmlstarlet`, falls `jq` nicht verwendet wird)
PRICES=$(echo "$RESPONSE" | xmlstarlet sel -t -m "//TimeSeries/Period/Point" -v "concat(position(), 'h: ', ./price.amount, ' EUR/MWh')" -n)

# Ausgabe der Preise
if [[ -z "$PRICES" ]]; then
    echo "Fehler: Konnte keine Strompreise extrahieren."
    exit 1
fi

echo "Börsenstrompreis für morgen ($TOMORROW):"
echo "$PRICES"

