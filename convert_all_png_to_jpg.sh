#!/bin/bash

pics=$(ls *.png)

for i in $pics
do
    convert $i ${i%.png}.jpg
done
