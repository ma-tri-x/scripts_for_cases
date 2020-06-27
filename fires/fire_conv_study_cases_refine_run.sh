#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

# ../conv_study_3mum_refine \
# ../conv_study_2mum_refine \
study_cases=" \
../conv_study_1.35mum_refine \
../conv_study_1mum_refine \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
