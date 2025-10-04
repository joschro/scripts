#!/bin/sh

myPID="$(ps aux|grep "livewebcam" | grep -v "$0" | grep -v "grep" | tr -s " " | cut -d" " -f2)"
test -z "$myPID" && exit
ps aux | grep -v "grep" | grep "$myPID" && kill "$myPID"

ps aux | grep livewebcam.py | grep -v grep || python ~/bin/livewebcam.py &
