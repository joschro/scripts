#!/bin/sh

test $# -lt 1 -o ! -d "$1" && { echo -e "Usage: $0 <path-to-config> [<percent>]"; exit; }

configPath="$1"
shift

ntfyPath=~/bin
ntfyTopic="$(cat $configPath/ntfy_info.topic)"

test $# -lt 1 && {
	LAT="$(cat $configPath/location.lat)"
	LON="$(cat $configPath/location.lon)"

	# Wetterdaten abrufen
	RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunshine_duration&timezone=Europe/Berlin")

	# Sonnenstunden für morgen extrahieren
	SUN_SECS=$(echo $RESPONSE | jq '.daily.sunshine_duration[0]')
	#SUN_SECS="$(echo "2 * 3600" | bc -l)"
	SUN_HOURS="$(echo $SUN_SECS / 3600 | bc)"
	# 8h = 8 * 3600s: percentGoal -> 10
	# 1h = 1 * 3600s: percentGoal -> 90
	# 0h = 0 * 3600s: percentGoal -> 100
	percent8h=10
	percent1h=90
	# f(x)= (percent8h - percent1h) / (7 * 3600) * x + ( 8 * percent8h - percent1h ) / 7
	a=$(echo "scale=4; ($percent8h - $percent1h) / (7 * 3600)" | bc -l)
	#; echo "a=$a"
	b=$(echo "scale=4; $percent8h - $a * 8 * 3600" | bc -l)
	#; echo "b=$b"
	percentGoal="$(echo "scale=0; (( $a * $SUN_SECS + $b ) + 0.5 ) / 1" | bc)"
	#; echo "percentGoal=$percentGoal"
	#percentGoal="$(echo "scale=0; ($percent8h - $percent1h) / (7 * 3600) * $SUN_SECS + ( 8 * $percent8h - $percent1h ) / 7" | bc -l)"
	#echo $SUN_SECS $SUN_HOURS $percentGoal $percent8h $percent1h
}
test $# -ge 1 && {
	test "$1" -gt 100 -o "$1" -lt 1 && { echo -e "Usage: $0 <path-to-config> [<percent>]"; exit; }
	test "$1" -le 100 -a "$1" -gt 0 && percentGoal="$1"
}

percentNow="$(sh ~/bin/sonnenbatterie.sh ~/Projekte/github/private --nontfy status | grep RemainingCapacity_% | sed "s/RemainingCapacity_%://g;s/%//g")"
percentDiff="$(echo "$percentGoal - $percentNow" | bc -l)"
numberOfQuarterlyHours="$(echo "scale=0; $percentDiff / 10" | bc -l)"

#echo percentGoal=$percentGoal
#echo percentNow=$percentNow
#echo percentDiff=$percentDiff
#echo numberOfQuarterlyHours=$numberOfQuarterlyHours
#runCMD="$(echo at "\"$(sh ~/bin/tibber-fetch-prices.sh $configPath $numberOfQuarterlyHours)\" <<< \'sh ~/bin/sonnenbatterie.sh ~/Projekte/github/private --until $percentGoal laden\'")"
runCMD="$(echo \"echo "sh ~/bin/sonnenbatterie.sh ~/Projekte/github/private --until $percentGoal laden" \| at -t \"$(sh ~/bin/tibber-fetch-prices.sh $configPath $numberOfQuarterlyHours)\"\")"
echo "sh ~/bin/sonnenbatterie.sh ~/Projekte/github/private --until $percentGoal laden" | at -t "$(sh ~/bin/tibber-fetch-prices.sh $configPath $numberOfQuarterlyHours)"
echo $runCMD
${ntfyPath}/ntfy.sh "$ntfyTopic" 'at command scheduled' "\"$runCMD\""
#$runCMD
