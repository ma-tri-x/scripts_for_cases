#!/bin/bash

thisdir=$(pwd)

all_cases=" \
../kk010_piston_axi_static \
../kk010_piston_axi_static_Rn184.1mum_dinit30mum \
../kk010_piston_axi_static_Rn240.0mum_dinit30mum \
../kk010_piston_axi_static_Rn184.1mum_dinit90mum \
../kk010_piston_axi_static_Rn201.5mum_dinit90mum \
../kk010_piston_axi_static_Rn240.0mum_dinit90mum \
../kk010_piston_axi_static_Rn184.1mum_dinit150mum \
../kk010_piston_axi_static_Rn201.5mum_dinit150mum \
../kk010_piston_axi_static_Rn240.0mum_dinit150mum \
"

all_cases="\
../kk010_piston_axi_static_Rn184.1mum_dinit90mum \
"

for i in $all_cases;do
    #echo $i
    cd $i
    fname=$(ls anim/kk010_p*0000.png)
    name=${fname%.0000.png}
    echo ${name#anim/}
    ffmpeg -pattern_type sequence -framerate 15 -i ${name}.%04d.png -b:v 6M -c:v mpeg4 ${name}.avi
    cp ${name}.avi $thisdir
    cd $thisdir
done
