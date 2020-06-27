#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}
# ../conv_study_3mum_Econst \
# ../conv_study_2mum_Econst \
# ../conv_study_1.35mum_Econst \
# ../conv_study_1.2mum_Econst \
# ../conv_study_1mum_Econst \

study_cases=" \
../conv_study_0.5mum_Econst_wp14 \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
