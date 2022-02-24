#!/bin/sh

test $# -lt 1 && {
	echo "Syntax: $0 <role-dir>"
	exit
}
test -d "$1" || {
	echo "$1 does not exist"
        exit
}

myREADME="$(cat "$1"/README.md)"
ansible-galaxy role init -f "$1"
roleREADME="$(cat "$1"/README.md)"
cat > "$1"/README.md <<EOF
$myREADME

$roleREADME
EOF
