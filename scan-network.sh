#!/bin/sh

networkBase="$(ip route |grep default | head -n1|sed "s/.*via //;s/ .*//;s/\(.*\)\..*/\1/")"
test $# -gt 0 && networkBase="$1"
#sudo nmap -T5 -sP ${networkBase}.0-255
nmap -T3 -sP ${networkBase}.0-255
