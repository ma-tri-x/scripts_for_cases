#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    localMassCorr_working_f0f82d3 > run.log 2>&1 &
}


# study_cases=" \
# ../sp_conv_study_3mum_int3cells \
# ../sp_conv_study_2mum_int3cells \
# ../sp_conv_study_1.35mum_int3cells \
# ../sp_conv_study_1mum_int3cells \
# ../sp_conv_study_0.6mum_int3cells \
# ../sp_conv_study_0.4mum_int3cells \
# "
# study_cases=" \
# ../sp_conv_study_3mum_GMC_int3cells \
# ../sp_conv_study_2mum_GMC_int3cells \
# ../sp_conv_study_1.35mum_GMC_int3cells \
# ../sp_conv_study_1mum_GMC_int3cells \
# ../sp_conv_study_0.6mum_GMC_int3cells \
# ../sp_conv_study_0.4mum_GMC_int3cells \
# "
# ../sp_conv_study_0.2mum \
# study_cases=" \
# ../sp_conv_study_3mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_2mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_1.35mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_1mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_0.6mum_GMC_int3cells_sigma0 \
# ../sp_conv_study_0.4mum_GMC_int3cells_sigma0 \
# "

# study_cases=" \
# ../sp_conv_study_3mum_int3cells_XF100 \
# ../sp_conv_study_2mum_int3cells_XF100 \
# ../sp_conv_study_1.35mum_int3cells_XF100 \
# ../sp_conv_study_1mum_int3cells_XF100 \
# ../sp_conv_study_0.6mum_int3cells_XF100 \
# ../sp_conv_study_0.4mum_int3cells_XF100 \
# "

# study_cases=" \
# ../sp_conv_study_3mum_int3cells_CLmesh \
# ../sp_conv_study_2mum_int3cells_CLmesh \
# ../sp_conv_study_1.35mum_int3cells_CLmesh \
# ../sp_conv_study_1mum_int3cells_CLmesh \
# ../sp_conv_study_0.6mum_int3cells_CLmesh \
# ../sp_conv_study_0.4mum_int3cells_CLmesh \
# "
# study_cases=" \
# ../sp_conv_study_3mum_CLmesh \
# ../sp_conv_study_2mum_CLmesh \
# ../sp_conv_study_1.35mum_CLmesh \
# ../sp_conv_study_1mum_CLmesh \
# ../sp_conv_study_0.6mum_CLmesh \
# ../sp_conv_study_0.4mum_CLmesh \
# "

study_cases=" \
../sp_conv_study_3mum_XF100 \
../sp_conv_study_2mum_XF100 \
../sp_conv_study_1.35mum_XF100 \
../sp_conv_study_1mum_XF100 \
../sp_conv_study_0.6mum_XF100 \
../sp_conv_study_0.4mum_XF100 \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done

sleep 2

l=0
for i in $study_cases
do
    let 'l=l+1'
    tail -n 15 $i/run.log
done

echo "\n\nYou should have $l threads of localMassCorr_working_f0f82d3"
