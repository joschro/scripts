#!/bin/sh

echo -n "ARE YOU SURE? THIS WILL DELETE ALL APP DATA ON YOUR PHONE! (Y/N): "; read ANSW; test "$ANSW" = "Y" || exit
for I in $(adb shell pm list packages -e -3 | sed "s/package://g" ); do echo -n "Clearing cache of $I: "; adb shell pm clear $I; done
