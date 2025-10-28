#!/bin/sh

test $# -lt 2 && { echo -e "Usage: $0 <path-to-config> <percent>"; exit; }

percentGoal="$2"
percentNow="$(sonnenbatterie.sh ~/Projekte/github/private --nontfy status | grep RemainingCapacity_% | sed "s/RemainingCapacity_%://g;s/%//g")"
percentDiff="$(echo "$percentGoal - $percentNow" | bc -l"
numberOfQuarterlyHours="$(echo "scale=0; $percentDiff / 10" | bc -l)"

echo at "$(sh ~/bin/tibber-fetch-prices.sh $1 $numberOfQuarterlyHours)"
