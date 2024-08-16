#!/bin/sh

networkBase="$1"
sudo nmap -T5 -sP ${networkBase}.0-255
