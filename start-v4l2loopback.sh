#!/bin/sh

V4L_DEV_NR=10

sudo modprobe v4l2loopback devices=1 video_nr=$V4L_DEV_NR card_label="RTMP server" exclusive_caps=1
sudo modprobe snd-aloop index=10 id="OBS Mic"
pacmd 'update-source-proplist alsa_input.platform-snd_aloop.0.analog-stereo device.description=\"OBS Mic\" '
sudo ffmpeg -f flv -listen 1 -i rtmp://127.0.0.1:1935/live -vf hflip -f v4l2 -vcodec rawvideo /dev/video$V4L_DEV_NR
#sudo ffmpeg -probesize 32 -analyzeduration 0 -listen 1 -i rtmp://127.0.0.1:1935/live/test -map 0:1 -f v4l2 -vcodec rawvideo /dev/video$V4L_DEV_NR -map 0:0 -f alsa hw:10,1
sudo rmmod v4l2loopback
