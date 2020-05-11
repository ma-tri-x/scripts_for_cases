#!/bin/bash

thisdir=$(pwd)
for i in ../dstar_*;do
    echo $i
    cp render_inkmaps.py $i
    cp $thisdir/states/inkmap_axisymm.pvsm* $i/states/
    cd $i
    python render_inkmaps.py
    cp ${i#../}.png $thisdir/final_inkmap_${i#"../"}.png
    cd $thisdir
done
