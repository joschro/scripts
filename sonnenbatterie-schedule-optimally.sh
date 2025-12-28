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
	echo "SUN_HOURS=$SUN_HOURS"
	# 8h = 8 * 3600s: percentGoal -> 10
	# 1h = 1 * 3600s: percentGoal -> 90
	# 0h = 0 * 3600s: percentGoal -> 100
	percent8h=15
	percent1h=95
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
numberOfQuarterlyHours="$(echo "scale=0; $percentDiff / 10 + 1" | bc -l)"

echo percentGoal=$percentGoal
echo percentNow=$percentNow
echo percentDiff=$percentDiff
echo numberOfQuarterlyHours=$numberOfQuarterlyHours
timeStart="$(sh ~/bin/tibber-fetch-prices.sh $configPath $numberOfQuarterlyHours)"
echo timeStart=$timeStart
timeStartS="$(date -d "$(echo $timeStart | sed "s/\(....\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5/g")" +"%s")"
echo timeStartS=$timeStartS
#timeNow="$(date '+%Y%m%d%H%M%S')"
timeNow="$(date '+%s')"
echo timeNow=$timeNow
timeDiff="$(echo "($timeStartS - $timeNow) / 60" | bc)"
echo timeDiff=$timeDiff
percentGoal="$(echo "$percentGoal + ( $timeDiff / 60 ) * 5" | bc)"
# wenn timeStartS + numberOfQuarterlyHours < 09:00 dann percentGoal
echo "$timeStartS + $numberOfQuarterlyHours * 15 * 60"
echo "$timeStartS + $numberOfQuarterlyHours * 15 * 60" | bc -l
timeEndS="$(echo "$timeStartS + $numberOfQuarterlyHours * 15 * 60" | bc)"
echo "timeEndS=$timeEndS"
timeDiff="$(echo "($(date -d "9:00 today" '+%s') - $timeEndS) / 60" | bc)"
echo timeDiff=$timeDiff
percentGoal="$(echo "$percentGoal + ( $timeDiff / 60 ) * 5" | bc)"
test $percentGoal -gt 93 && percentGoal=93
echo percentGoal=$percentGoal
test $percentDiff -lt 1 && { echo "percentGoal ($percentGoal) is less than percentNow ($percentNow), nothing to do."; exit; }
#exit
runCMD="echo \"sh ~/bin/sonnenbatterie.sh ~/Projekte/github/private --wbec 192.168.178.102 --until $percentGoal laden\" | at -t $timeStart"
echo "$runCMD"
eval "$runCMD"
${ntfyPath}/ntfy.sh "$ntfyTopic" 'at command scheduled' "$(echo $runCMD | sed 's/\"//g')"
#exit
runCMD="echo \"/usr/bin/curl -s \\\"http://192.168.178.194/cm?cmnd=Power1%20ON\\\"\" | at -t $timeStart"
echo "$runCMD"
eval "$runCMD"
${ntfyPath}/ntfy.sh "$ntfyTopic" 'at command scheduled' "$(echo $runCMD | sed 's/\"//g')"
