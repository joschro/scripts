#!/bin/sh

#echo "DEBUG CMDLINE: $0 $*"

internalFind=false
internalRemove=false
case "$1" in
        "--intFind")    {
                internalFind=true
                shift
        }
        ;;
        "--intRemove")  {
                internalRemove=true
                shift
        }
        ;;
esac


SRC="$1"
DST="$2"

#echo "DEBUG: internalFind=$internalFind internalRemove=$internalRemove $0 $*"
test -L "$SRC" && {
	echo "$SRC is a symbolic link, check manually!!"
	exit
}
test -L "$DST" && {
	echo "$DST is a symbolic link, check manually!!"
	exit
}

if $internalFind; then
#       echo "DEBUG: internalFind $SRC $DST"
        find "$DST" -type f -name "$(basename "$SRC")" -exec $0 --intRemove "$SRC" "{}" \;
elif $internalRemove; then
#       echo "DEBUG: internalRemove $SRC $DST"
        ls -l "$SRC" "$DST"; diff "$SRC" "$DST" && rm -iv "$SRC"
else
#       echo "DEBUG: external $SRC $DST"
        diff -qr "$SRC" "$DST" && {
                ls -l "$SRC" "$DST"
                echo -n "$SRC and $DST are identical - remove $SRC completely? [Y/N] "; read ANSW
                test "$ANSW" = "Y" && rm -vrf "$SRC"
                exit
        }
        echo "Find identical files from $SRC in $DST and delete them in $SRC :"
        find "$SRC" -type f -exec $0 --intFind "{}" "$DST" \;
fi
