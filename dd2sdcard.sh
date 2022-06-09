#!/bin/sh

myDEV=/dev/sda

test $# -gt 1 && myDEV=$2

test -f $1 || exit
test -e $myDEV || exit

cat /proc/partitions |grep -v dm- | grep -v nvme
echo

echo;echo "Write:"
ls -lh $1
echo
echo "$1" | grep "\.tar\.bz2$" && tar -tvjf "$1"
echo "$1" | grep "\.tar\.gz$" && tar -tvzf "$1"
echo "$1" | grep "\.gz$" && gunzip -l "$1"
echo "$1" | grep "\.xz$" && xzcat -l "$1"
echo "$1" | grep "\.zip$" && unzip -l "$1"


echo; echo "to:"
fdisk -l $myDEV
echo;echo "Do you really want to write to this device $myDEV? Cancel with <CTRL-C>..."; read ANSW

echo "$1" | grep "\.tar\.bz2$" && {
	echo "tar.bz2 detected"
	tar -xvjf "$1" -o | dd status=progress bs=4M of=$myDEV && sync;sync;sync
	exit 0
}
echo "$1" | grep "\.tar\.gz$" && {
	echo "tar.gz detected"
	tar -xvzf "$1" -o | dd status=progress bs=4M of=$myDEV && sync;sync;sync
	exit 0
}
echo "$1" | grep "\.gz$" && {
	echo "gunzip detected"
	gunzip -c "$1" | dd status=progress bs=4M of=$myDEV && sync;sync;sync
	exit 0
}
echo "$1" | grep "\.xz$" && {
	echo "xz detected"
	xzcat "$1" | dd status=progress bs=4M of=$myDEV && sync;sync;sync
	exit 0
}
echo "$1" | grep "\.zip$" && {
	echo "zip detected"
	unzip -p "$1" | dd status=progress bs=4M of=$myDEV && sync;sync;sync
	exit 0
}
echo "$1" | grep "\.img$\|\.iso$" && {
	echo "raw image detected"
	dd status=progress bs=4M conv=fdatasync if="$1" of=$myDEV && sync;sync;sync
	exit 0
}
