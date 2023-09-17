#!/bin/sh

echo
#echo "DEBUG CMDLINE: $0 $*"

internalFind=false
internalRemove=false
noDirDiff=false
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
	"--noDirDiff")	{
		noDirDiff=true
		shift
	}
	;;
esac


SRC="$1"
DST="$2"

#echo "DEBUG: noDirDiff=$noDirDiff internalFind=$internalFind internalRemove=$internalRemove $0 $*"
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
        echo;ls -l "$SRC" "$DST"; diff "$SRC" "$DST" && {
		echo;echo "$(basename "$SRC") in $(dirname "$SRC") and $(dirname "$DST") are identical!"
		rm -iv "$SRC"
	}
else
#       echo "DEBUG: external $SRC $DST"
test $noDirDiff == false && diff -qr "$SRC" "$DST" && {
		echo
                ls -l "$SRC" "$DST"
                echo -n "$SRC and $DST are identical - remove $SRC completely? [Y/N] "; read ANSW
                test "$ANSW" = "Y" && rm -vrf "$SRC"
                exit
        }
        echo "Find identical files from $SRC in $DST and delete them in $SRC :"
        find "$SRC" -type f -exec $0 --intFind "{}" "$DST" \;
fi
