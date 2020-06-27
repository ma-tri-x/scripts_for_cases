#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

study_cases=" \
../sp_conv_study_0.1mum_int3cells \
../sp_conv_study_0.05mum_int3cells \
../sp_conv_study_0.02mum_int3cells \
../sp_conv_study_0.2mum_int3cells \
"
# ../sp_conv_study_3mum \
# ../sp_conv_study_2mum \
# ../sp_conv_study_1.35mum \
# ../sp_conv_study_1mum \
# ../sp_conv_study_0.6mum \
# ../sp_conv_study_0.4mum \
# ../sp_conv_study_0.2mum \

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
