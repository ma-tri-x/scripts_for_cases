#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}


study_cases=" \
../conv_study_3mum_refine_low_res \
../conv_study_2mum_refine_low_res \
../conv_study_1.35mum_refine_low_res \
../conv_study_1mum_refine_low_res \
../conv_study_0.75mum_refine_low_res \
"
# ../conv_study_0.6mum_refine_low_res \

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
