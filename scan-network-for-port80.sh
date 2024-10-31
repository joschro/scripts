#/!bin/sh

networks="$(ip route |grep default | head -n1|sed "s/.*via //;s/ .*//;s/\(.*\)\..*/\1/")"
test $# -gt 0 && networks="$*"
range="3..19"
for J in $networks; do
	for I in {3..19}; do 
		IP="$J.$I"
		echo $IP
		curl -sk https://$IP:80/ | grep var
	done
done
