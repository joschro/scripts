#!/bin/sh

adb devices | grep device | grep -v attached || exit
myPHONE="$(adb shell getprop ro.product.manufacturer)"
myMODEL="$(adb shell getprop ro.product.brand_device_name)"
test -n "$myMODEL" || myMODEL="$(adb shell getprop ro.build.product)"
test -n "$myMODEL" || myMODEL="$(adb shell getprop ro.product.model)"
myPATH="$myPHONE/$myMODEL/$(date +"%Y-%m-%d")"
mkdir -p "$myPATH"
cd "$myPATH"
adb shell getprop ro.build.version.release > android-version.txt
adb shell getprop | grep -E "(model|manufacturer|brand|product|version)" > info-dump.txt
adb shell dumpsys battery > battery-stats.txt
android-list-installed-packages.sh
