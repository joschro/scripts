#!/bin/sh

echo "Syntax: $0 <remote files/dir>"
echo "        copies remote files/dir to current directory"
adb pull -a "$*" .
