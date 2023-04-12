#!/bin/sh

for I in /dev/video*; do
       v4l2-ctl -D -d $I | grep C920 && {
	       echo "Webcam found at: $I"
	       guvcview -z -d $I -p ~/configs/guvcview-videoconf-c920.gpfl
	       break
       }
       v4l2-ctl -D -d $I | grep C930e && {
	       echo "Webcam found at: $I"
	       guvcview -z -d $I -p ~/configs/guvcview-videoconf-c930e.gpfl
	       break
       }
       v4l2-ctl -D -d $I | grep Trust && {
	       echo "Webcam found at: $I"
	       guvcview -z -d $I -p ~/configs/guvcview-videoconf-trust.gpfl
	       break
       }
done

v4l2-ctl --list-formats
