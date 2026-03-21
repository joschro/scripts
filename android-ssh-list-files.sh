#!/bin/sh

myIP=$1
shift

remoteDir=/sdcard/
test $# -gt 0 && remoteDir=$1
ssh -p 2222 $myIP ls -lh $remoteDir
