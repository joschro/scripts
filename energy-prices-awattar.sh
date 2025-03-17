#!/bin/sh

#curl -s "https://api.awattar.com/v1/marketdata" | jq

# API-URL für Deutschland (für Österreich: https://api.awattar.at/v1/marketdata)
API_URL="https://api.awattar.com/v1/marketdata"

# Daten abrufen
RESPONSE=$(curl -s "$API_URL")

# Prüfen, ob Daten empfangen wurden
if [[ -z "$RESPONSE" || "$RESPONSE" == "null" ]]; then
    echo "Fehler: Keine Daten empfangen oder ungültige Antwort."
    exit 1
fi
#echo $RESPONSE
#echo "$RESPONSE" | jq -r '.data[]'
# Daten parsen und formatiert ausgeben
echo "📅 Strompreise für morgen (Startzeit, Preis):"
echo "---------------------------------------------"

#echo "$RESPONSE" | jq -r '
#  .data[] |
#  select(.marketprice != null) |  # Null-Werte entfernen
#  {zeit: (.start_timestamp / 1000 | strftime("%Y-%m-%d %H:%M")), preis: ((.marketprice / 10) * 100 | round / 100)} |
#  "🕒 \(.zeit) - 🔌 \(.preis) ct/kWh"
#'

#echo "$RESPONSE" | jq -r '
#  .data[] |
#  {zeit: (.start_timestamp / 1000 | strftime("%Y-%m-%d %H:%M")), preis: (.marketprice / 10)} |
#  "🕒 \(.zeit) - 🔌 \(.preis) ct/kWh"
#'

echo "$RESPONSE" | jq -r '
  .data |  # Zugriff auf das "data"-Array
  map(  # Umwandlung der Daten in ein Array von Objekten
    {
      zeit: (.start_timestamp / 1000 | strftime("%Y-%m-%d %H:%M")),
      preis: ((.marketprice / 10) * 100 | round / 100)
    }
  ) |
  # Sortiere das Array nach dem Preis
  sort_by(.preis) |
  # Ausgabe formatieren
  .[] | "🕒 \(.zeit) - € \(.preis) ct/kWh"
'
