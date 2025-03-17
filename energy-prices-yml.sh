#!/bin/bash

# Setze deinen API-Key hier
API_KEY="4b8479ae-a1c6-4a44-9608-f0166dcb6094"

# Setze die Marktzonen-ID für dein Land (Deutschland als Beispiel)
MARKET_AREA="10YDE-VE-------2"

# Datum für morgen im Format YYYYMMDD
TOMORROW=$(date -d "tomorrow" +"%Y%m%d")

# URL für die Day-Ahead-Preise
URL="https://web-api.tp.entsoe.eu/api?securityToken=$API_KEY&documentType=A44&in_Domain=$MARKET_AREA&out_Domain=$MARKET_AREA&periodStart=${TOMORROW}0000&periodEnd=${TOMORROW}2300"

# API-Abfrage durchführen
RESPONSE=$(curl -s "$URL")

# Prüfen, ob eine Antwort empfangen wurde
if [[ -z "$RESPONSE" ]]; then
    echo '{"error": "Keine Daten empfangen"}'
    exit 1
fi

# XML in JSON umwandeln und relevante Daten extrahieren
JSON_OUTPUT=$(echo "$RESPONSE" | xmlstarlet sel -t \
    -m "//TimeSeries/Period/Point" \
    -o '{ "hour": ' -v "position()" -o ', "price": ' -v "./price.amount" -o ' },' \
    | sed '$ s/,$//' | jq -s '.')

# Falls keine Daten extrahiert wurden, Fehler ausgeben
if [[ -z "$JSON_OUTPUT" || "$JSON_OUTPUT" == "[]" ]]; then
    echo '{"error": "Konnte keine Strompreise extrahieren"}'
    exit 1
fi

# JSON ausgeben
echo '{ "date": "'"$TOMORROW"'", "prices": '"$JSON_OUTPUT"' }'

