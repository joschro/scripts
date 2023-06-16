#!/bin/sh

fileList=""
for I in $*; do echo "$I"; test -f "$I" && fileList="$fileList $I"; done

qpdfview-qt5 $fileList
