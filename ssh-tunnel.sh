#!/bin/sh

# make sure to install cronie if you want to use crontabs for keeping the tunnel up

### make sure that on the remote side there "grep GatewayPort /etc/ssh/sshd_config" results in:
# #GatewayPorts no
# GatewayPorts yes

myDest="$1"
ssh $myDest sudo grep GatewayPort /etc/ssh/sshd_config | grep yes || exit
shift
myPort="55522"
test $# -gt 0 && myPort="$1"

ps aux | grep -v grep | grep "ssh -R 0.0.0.0:$myPort:127.0.0.1:22 -N $myDest" >/dev/null && {
	remoteIP="$(echo $myDest | sed "s/.*@//")"
        #echo "remoteIP: $remoteIP"
	ssh -p $myPort $remoteIP ps ax | grep "sshd: opc@notty" && exit
        kill $(ps aux | grep -v grep | grep "ssh -R 0.0.0.0:$myPort:127.0.0.1:22 -N $myDest" | tr -s [:blank:] | cut -d" " -f 2 | head -n1)
}

nohup ssh -R 0.0.0.0:$myPort:127.0.0.1:22 -N $myDest >/dev/null 2>&1 &
