#!/bin/sh

test $# -lt 2 || {
	echo "Syntax: $(basename $0) <file1> <file2>"
	echo "	if file1 and file2 are identical, file1 will be removed"
	echo
}

SRC="$1"
DST="$2"

echo;echo "Comparing $SRC and $DST :"
ls -l "$SRC" "$DST"
diff "$SRC" "$DST" && rm -v "$SRC"
