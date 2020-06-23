#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

study_cases=" \
../conv_study_3mum_unbound_int3cells \
../conv_study_2mum_unbound_int3cells \
../conv_study_1.35mum_unbound_int3cells \
../conv_study_1mum_unbound_int3cells \
../conv_study_0.75mum_unbound_int3cells \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
