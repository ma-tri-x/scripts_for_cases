#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun --map-by core -np 16 --bind-to core localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

# study_cases=" \
# ../sp_conv_study_0.1mum \
# ../sp_conv_study_0.05mum \
# ../sp_conv_study_0.02mum \
# "
# study_cases=" \
# ../sp_conv_study_0.07mum_GMC_int3cells \
# "

study_cases=" \
../sp_conv_study_0.07mum_GMC_int3cells_sigma0 \
"

# ../sp_conv_study_0.2mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_0.1mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_0.09mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_0.09mum_GMC_int3cells \
# ../sp_conv_study_0.2mum_GMC_int3cells \
# ../sp_conv_study_0.1mum_GMC_int3cells \
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
