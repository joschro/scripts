#!/bin/sh

networkBase="$1"
nmap -T5 -sP ${networkBase}.0-255
