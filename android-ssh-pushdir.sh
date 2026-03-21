#!/bin/sh

remoteIP=$1
shift
localDir=.
remoteDir=/sdcard/

echo "Syntax: $0 <IP address> <local file/dir> [remote dir]"
echo "        copies local file/dir to remote directory"
test $# -gt 0 && localDir=$1 && shift
test $# -gt 0 && remoteDir=$1

rsync -e "ssh -p 2222" -vauP $localDir $remoteIP:$remoteDir
