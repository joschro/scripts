#!/bin/sh

remoteIP=$1
shift
remoteDir=/sdcard/

echo "Syntax: $0 <IP address> [remote files/dir]"
echo "        copies remote files/dir to current directory"
test $# -gt 0 && remoteDir=$1

rsync -e "ssh -p 2222" -vauP $remoteIP:$remoteDir .
