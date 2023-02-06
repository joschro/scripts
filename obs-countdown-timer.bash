#!/bin/bash 

### original script taken from https://github.com/tomxue/countdown
### changes inspired by the countdown timer script I got from Joachim Schroder via work chat on 2021-10-25

# This script is meant to be used to show a remaining meeting time in OBS
# just have OBS display the file set as outFile
#
# if you want to also show seconds, then adjust the echo statement below
#
# pcfe, 2021-11-05

outFile=~/.obs-countdown-timer.txt

if [ "$#" -lt "2" ] ; then
  echo "Incorrect usage ! Example:"
  echo "$0 -d  'Jun 10 2022 16:06'"
  echo "or"
  echo "$0 -d  16:06"
  echo "or"
  echo "$0 -m  90"
  exit 1
fi

now=`date +%s`

# specify a time mode
if [ "$1" = "-d" ] ; then
  until=`date -d "$2" +%s`
  sec_rem=`expr $until - $now`
  echo "-d (date mode) used"
  if [ $sec_rem -lt 1 ]; then
    echo "$2 is already history !"
    exit 1
  fi
fi

# minutes remaining mode
if [ "$1" = "-m" ] ; then
  until=`expr 60 \* $2`
  until=`expr $until + $now`
  sec_rem=`expr $until - $now`
  echo "-m (minutes mode) used"
  if [ $sec_rem -lt 1 ]; then
    echo "$2 is already history !"
    exit 1
  fi
fi

# countdown
while [ $sec_rem -gt 0 ]; do
  interval=$sec_rem
  seconds=`expr $interval % 60`
  interval=`expr $interval - $seconds`
  minutes=`expr $interval % 3600 / 60`
  interval=`expr $interval - $minutes`
  hours=`expr $interval % 86400 / 3600`
  interval=`expr $interval - $hours`
  days=`expr $interval % 604800 / 86400`
  interval=`expr $interval - $hours`
  weeks=`expr $interval / 604800`
  #echo "${hours}h ${minutes}m left" | tee $outFile
  figlet "${hours}h ${minutes}m left" | tee $outFile
  # echo "Δt ${hours}h ${minutes}m" | tee $outFile
  let sec_rem=$sec_rem-1
  sleep 1
done

# blink for a while after countdown reaches zero
blinknum=50
while [ $blinknum -gt 0 ]; do
  echo "END REACHED" | tee $outFile
  sleep 3
  echo " " | tee $outFile
  sleep 3
  let blinknum=$blinknum-1
done
