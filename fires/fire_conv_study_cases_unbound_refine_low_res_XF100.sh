#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

study_cases=" \
../conv_study_3mum_unbound_refine_low_res_XF100 \
../conv_study_2mum_unbound_refine_low_res_XF100 \
../conv_study_1.35mum_unbound_refine_low_res_XF100 \
../conv_study_1mum_unbound_refine_low_res_XF100 \
../conv_study_0.75mum_unbound_refine_low_res_XF100 \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
