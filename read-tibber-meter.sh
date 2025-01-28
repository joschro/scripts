#!/bin/sh

test $# -lt 2 && {
	echo "Syntax: $0 <topic> <tibber-bridge-password>"
        exit
}

myTopic="$1"
shift

ntfy.sh "$myTopic" "Stromzählerstände" "$(curl -s -u admin:"$1" http://192.168.178.105/data.json?node_id=1 | python3 ~/bin/pysmlparser.py | grep Total)"
