#!/bin/bash

test $# -lt 1 && { echo -e "Usage: $0 <path-to-config>"; exit; }
API_TOKEN="$(cat $1/api_keys/tibber_token.txt)"
HOME_ID="$(cat $1/tibber_home_id.txt)"

#curl \
#-H "Authorization: Bearer $API_TOKEN" \
#-H "Content-Type: application/json" \
#-X POST \
#-d  '{ "query": "{viewer {homes {currentSubscription {priceInfo {current {total energy tax startsAt }}}}}}" }' https://api.tibber.com/v1-beta/gql
#

#curl -s \
#  -H "Authorization: Bearer $API_TOKEN" \
#  -H "Content-Type: application/json" \
#  -X POST \
#  -d '{"query": "{ viewer { homes { id }}}"}' \
#  https://api.tibber.com/v1-beta/gql

QUERY='{ "query": "query { viewer { home(id: \"'$HOME_ID'\") { currentSubscription { priceInfo(resolution: QUARTER_HOURLY) { today { total energy tax startsAt } tomorrow { total energy tax startsAt } } } } } }" }'

#curl -s \
#  -H "Authorization: Bearer $API_TOKEN" \
#  -H "Content-Type: application/json" \
#  -X POST \
#  -d '{"query": "{viewer {homes(id: \"'$HOME_ID'\") {currentSubscription {priceInfo {today {total energy tax startsAt } tomorrow {total energy tax startsAt }}}}}}"}' \
#  https://api.tibber.com/v1-beta/gql

# ... | jq '.data.viewer.homes[0].currentSubscription.priceInfo.today[] | {start: .startsAt, price: .total}'

response=$(curl -s \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$QUERY" \
  https://api.tibber.com/v1-beta/gql)

#echo "$response" | jq '.data.viewer.home.currentSubscription.priceInfo.today[] | {start: .startsAt, price: .total}'

#echo "$response" | jq '
#  .data.viewer.home.currentSubscription.priceInfo.today
#  | min_by(.total)
#  | {min_price: .total, date: (.startsAt | split("T")[0]), time: (.startsAt | split("T")[1])}
#'

#echo "$response" | jq '
#  .data.viewer.home.currentSubscription.priceInfo.today
#  | min_by(.total)
#  | {min_price: .total, time: .startsAt}
#'

now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
#echo "$response" | jq --arg now "$now" '
#  [
#    .data.viewer.home.currentSubscription.priceInfo.today[],
#    .data.viewer.home.currentSubscription.priceInfo.tomorrow[]?
#  ]
#  | map(select(.startsAt > $now))
#  | min_by(.total)
#  | {min_price: .total, date: (.startsAt | split("T")[0]), time: (.startsAt | split("T")[1])}
#'

#echo "$response" | jq --arg now "$now" '
#  [
#    .data.viewer.home.currentSubscription.priceInfo.today[],
#    .data.viewer.home.currentSubscription.priceInfo.tomorrow[]?
#  ]
#  | [ .[] | select(.startsAt > $now) ]
#  | (min_by(.total) | .startsAt) as $minstart
#  | to_entries
#  | map(.value.startsAt) as $startsArray
#  | ($startsArray | index($minstart)) as $minidx
#  | if $minidx == null or $minidx < 4 then "Zu wenige zukünftige Intervalle vorhanden!"
#    else $startsArray[$minidx - 4]
#    end
#'

window=12
test $# -gt 1 && window=$2
datetime_iso=$(echo "$response" | jq --arg now "$now" --argjson win $window '
  [
    .data.viewer.home.currentSubscription.priceInfo.today[], 
    .data.viewer.home.currentSubscription.priceInfo.tomorrow[]?
  ]
  | map(select(.startsAt > $now))
  | . as $arr
  | $arr | length as $len
  | [range(0; $len - $win + 1)
     | {
       start: $arr[.].startsAt,
       sum: ($arr[.:(. + $win)] | map(.total) | add)
     }
    ]
  | min_by(.sum)
  | .start
' | tr -d '"')

# ISO-Zeit in „at“-kompatibles Format umwandeln: „HH:MM YYYY-MM-DD“
datetime_at=$(date -d "$datetime_iso" '+%H:%M %Y-%m-%d')

echo "$datetime_at"
