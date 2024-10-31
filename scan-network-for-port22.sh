#!/bin/sh

networkBase="$(ip route |grep default | head -n1|sed "s/.*via //;s/ .*//;s/\(.*\)\..*/\1/")"
test $# -gt 0 && networkBase="$1"
sudo nmap -p 22 -T5 ${networkBase}.0-255
