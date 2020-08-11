#!/bin/bash

study_cases=$(ls .. | grep sp_conv)

thisdir=$(pwd)

for i in $study_cases
do
    cd ../$i
    time=$(python find_biggestNumber.py -p .)
    echo "$i   $time "
    cd $thisdir
done
