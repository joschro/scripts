#!/bin/sh

fileList=""
for I in $*; do echo "$I"; test -f "$I" && fileList="$fileList $I"; done

for I in qpdfview-qt6 qpdfview-qt5; do
	test -f /usr/bin/$I && $I $fileList
done
