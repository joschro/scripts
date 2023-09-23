#!/bin/sh

SRC="$1"
DST="$2"

echo;echo "Comparing $SRC and $DST :"
ls -l "$SRC" "$DST"
diff "$SRC" "$DST" && rm -v "$SRC"
