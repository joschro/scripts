#!/bin/sh

fileList=""
for I in $*; do test -f "$I" && $fileList="$fileList $I"; done

qpdfview-qt5 $fileList
