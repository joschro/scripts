#!/bin/sh
myDEV=/dev/sda

myFDISK="sudo fdisk"
myDD="sudo arm-image-installer"

test "$USER" = "root" && {
        myFDISK="fdisk"
        myDD="arm-image-installer"
}

test $# -gt 1 && myDEV=$2

test -f $1 || {
        echo "Error: $1 not a file"
        exit
}
test -e $myDEV || {
        echo "Error: $myDEV does not exit"
        exit
}

cat /proc/partitions |grep -v dm- | grep -v nvme
echo

echo;echo "Write:"
ls -lh $1
echo
echo "$1" | grep "\.tar\.bz2$" && tar -tvjf "$1"
echo "$1" | grep "\.tar\.gz$" && tar -tvzf "$1"
echo "$1" | grep "\.bz2$" && echo "$1" | sed "s/\.bz2//"
echo "$1" | grep "\.gz$" && gunzip -l "$1"
echo "$1" | grep "\.xz$" && xzcat -l "$1"
echo "$1" | grep "\.zip$" && unzip -l "$1"
echo "$1" | grep "\.zst$" && zstd -l "$1"


echo; echo "to:"
$myFDISK -l $myDEV
echo;echo "Do you really want to write to this device $myDEV? Cancel with <CTRL-C>..."; read ANSW

$myDD --showboot --resizefs --target=rpi02w --image="$1"  --media=$myDEV

sync;sync;sync
