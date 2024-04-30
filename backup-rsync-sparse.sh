#!/bin/sh

echo "Syntax: $0 <src_dir> <dst_dir>"
test $# -lt 3 && exit
rsync -vauPs "$1" "$2"
