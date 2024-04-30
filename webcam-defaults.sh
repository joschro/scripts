#!/bin/sh

myParams="-z -g none"
for I in /dev/video*; do
       v4l2-ctl -D -d $I | grep C920 && {
	       echo "Webcam found at: $I"
	       guvcview $myParams -d $I -p ~/configs/guvcview-videoconf-c920.gpfl
	       break
       }
       v4l2-ctl -D -d $I | grep C922 && {
	       echo "Webcam found at: $I"
	       guvcview $myParams -d $I -p ~/configs/guvcview-videoconf-c922.gpfl
	       break
       }
       v4l2-ctl -D -d $I | grep C930e && {
	       echo "Webcam found at: $I"
	       guvcview $myParams -d $I -p ~/configs/guvcview-videoconf-c930e.gpfl
	       break
       }
       v4l2-ctl -D -d $I | grep Trust && {
	       echo "Webcam found at: $I"
	       guvcview $myParams -d $I -p ~/configs/guvcview-videoconf-trust.gpfl
	       break
       }
done
echo
v4l2-ctl --list-devices
echo
v4l2-ctl --list-formats
