#!/bin/bash

thisdir=$(pwd)

for i in ../conv_study_*Econst;do
    rm $i/contour/bla*
    cd $i
    python render_2D_contours.py
    python merge_split_files.py
    cd $thisdir
done
