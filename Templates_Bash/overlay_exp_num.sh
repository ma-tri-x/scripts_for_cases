#!/bin/bash


if [ $# -ne 2 ]
then
    echo "usage: $0 <num file prefix> <exp file prefix>"
    exit 0
fi

i=0

while [ -e "$1${i}.png" ]
do
        set -x
	convert -composite $2${i}.png $1${i}.png -geometry +238-100 result${i}.png
	set +x
	let "i = i + 1"
done
