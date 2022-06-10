#!/bin/sh

#v4l2-ctl --list-devices
#echo -n "Select video output number: ";read answer
vlc v4l2:///dev/video2
