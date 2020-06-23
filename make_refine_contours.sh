#!/bin/bash

thisdir=$(pwd)

study_cases=" \
../conv_study_1.35mum_refine \
../conv_study_1mum_refine \
../conv_study_3mum_refine \
../conv_study_2mum_refine \
../conv_study_0.75mum_refine \
"
# ../conv_study_0.6mum_refine \

for i in $study_cases
do
    cd $i
    python render_2D_contours.py
    python merge_split_files.py
    cd $thisdir
done
