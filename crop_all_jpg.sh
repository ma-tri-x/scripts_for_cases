#!/bin/bash

pics=$(ls *.jpg)

for i in $pics
do
    convert -trim $i $i
done
