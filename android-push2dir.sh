#!/bin/sh

echo "Syntax: $0 <local files/dir>.. <remote-dir>"
adb push --sync $*
