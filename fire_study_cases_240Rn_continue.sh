#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run2.log 2>&1
}

# study_cases=" \
# ../kk010_piston_axi_static_Rn240.0mum_dinit90mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit150mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit30mum \
# "

study_cases=" \
../kk010_piston_axi_static_Rn240.0mum_dinit250mum \
../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma \
"

for i in $study_cases;do
    cd $i
    sed -i "s/startFrom.*;/startFrom    latestTime;/g" system/controlDict
    sed -i "s/endTime.*;/endTime    120e-6;/g" system/controlDict
    fire
    cd $thisdir
done
