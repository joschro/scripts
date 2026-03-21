#!/bin/sh

remoteDir=/sdcard/
test $# -gt 0 && remoteDir=$1
adb shell ls -lh $remoteDir
