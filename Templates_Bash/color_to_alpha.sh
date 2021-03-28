#!/bin/bash

# script to reduce the red of paraview scale to transparent:

if [ $# -ne 2 ]
then
    echo "usage: $0 <input.png> <output.png>"
    exit 0
fi

set -x

# where the smaller the %, the closer to true white or conversely, the larger the %, the more variation from white is allowed to become transparent:

convert $1 -fuzz 25% -transparent "#8d031c" out.png

#make semi transparent:
convert out.png -alpha set -background none -channel A -evaluate multiply 0.5 +channel $2