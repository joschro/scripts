#/!bin/sh

networks="10.93.124"
test $# -gt 0 && networks="$*"
range="3..19"
for J in $networks; do
	for I in {3..19}; do 
		IP="$J.$I"
		echo $IP
		curl -sk https://$IP:9090/ | grep var
	done
done
