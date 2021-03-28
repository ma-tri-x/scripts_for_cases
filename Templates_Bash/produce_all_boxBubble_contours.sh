#!/bin/bash

thisdir=$(pwd)

for i in ../0071_dstar1.6_from_sose2019_boxBubble*;do
    rm $i/contour/bla*
    cd $i
    python render_2D_contours.py
    python merge_split_files.py
    cd $thisdir
done
