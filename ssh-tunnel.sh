#!/bin/sh

# make sure to install cronie if you want to use crontabs for keeping the tunnel up

### make sure that on the remote side there "grep GatewayPort /etc/ssh/sshd_config" results in:
# #GatewayPorts no
# GatewayPorts yes

test $# -lt 1 && {
	echo "$0 <host> [port on host (55522)] [local port (22)] [local ip address (127.0.0.1)]"
	echo
	cat <<EOF
# make sure to install cronie if you want to use crontabs for keeping the tunnel up

### make sure that on the remote side there "grep GatewayPort /etc/ssh/sshd_config" results in:
# #GatewayPorts no
# GatewayPorts yes
EOF
	exit
}

myDest="$1"
shift
ssh $myDest sudo grep GatewayPort /etc/ssh/sshd_config | grep yes || exit

myPort="55522"
test $# -gt 0 && {
	myPort="$1"
	shift
}
servicePort="22"
test $# -gt 0 && {
	servicePort="$1"
	shift
}
serviceIP="127.0.0.1"
test $# -gt 0 && {
	serviceIP="$1"
	shift
}

ps aux | grep -v grep | grep "ssh -R 0.0.0.0:$myPort:$serviceIP:$servicePort -N $myDest" >/dev/null && {
	remoteIP="$(echo $myDest | sed "s/.*@//")"
        #echo "remoteIP: $remoteIP"
	ssh -p $myPort $remoteIP ps ax | grep "sshd: opc@notty" && exit
        kill $(ps aux | grep -v grep | grep "ssh -R 0.0.0.0:$myPort:$serviceIP:$servicePort -N $myDest" | tr -s [:blank:] | cut -d" " -f 2 | head -n1)
}

nohup ssh -R 0.0.0.0:$myPort:$serviceIP:$servicePort -N $myDest >/dev/null 2>&1 &

# autossh restarts ssh tunnels automatically:
#nohup autossh -f -R 0.0.0.0:$myPort:$serviceIP:$servicePort -N $myDest >/dev/null 2>&1
