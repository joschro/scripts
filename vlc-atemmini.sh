#!/bin/sh

#v4l2-ctl --list-devices
#echo -n "Select video output number: ";read answer
myDev=$(v4l2-ctl --list-devices | grep -A3 Blackmagic | grep video | head -n1 | tr -d [:cntrl:])
echo "Display $myDev"
vlc v4l2://$myDev
