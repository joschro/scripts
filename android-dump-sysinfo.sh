#!/bin/sh

# https://www.droidviews.com/adb-fastboot-commands-android/

adb shell dumpsys user | grep -i userinfo{
adb shell dumpsys display
adb shell dumpsys battery
adb shell dumpsys batterystats
#adb shell netstat
#adb shell getprop

