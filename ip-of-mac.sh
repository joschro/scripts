#!/bin/sh

ping -q -4 -c1 -b 255.255.255.255 >/dev/null 2>&1
IPs="$(ip neigh show)"
MACIPs=""

for MAC in $*; do
	MACIPs="${MACIPs}$(echo -n "$IPs" | grep -i "$MAC" | cut -d" " -f1 | sort -u) "
done

test -n "$MACIPs" && echo "$MACIPs" | grep "[0-9]" >/dev/null && {
       echo "$MACIPs"
       exit
}

networkBase="$(ip route |grep default | head -n1|sed "s/.*via //;s/ .*//;s/\(.*\)\..*/\1/")"

nmap -T3 -sP ${networkBase}.0-255 >/dev/null 2>&1
IPs="$(arp -n |tr -s " " | cut -d " " -f1,3 | sort -u)"
for MAC in $*; do
        MACIPs="${MACIPs}$(echo -n "$IPs" | grep -i "$MAC" | head -n1 | sed "s/ .*//g") "
done

#IPs="$(sudo nmap -T3 -sP ${networkBase}.0-255)"
#for MAC in $*; do
#        MACIPs="${MACIPs}$(echo -n "$IPs" | grep -B2 -i "$MAC" | head -n1 | sed "s/.* //g") "
#done

test -n "$MACIPs" && echo "$MACIPs" | grep "[0-9]" >/dev/null && {
       echo "$MACIPs"
       exit
}

echo "MAC not found."
#echo "$*" | grep "looped" | grep -v grep >/dev/null || $0 $* looped
