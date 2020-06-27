#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

# study_cases=" \
# ../kk010_piston_axi_static_Rn184.1mum_dinit90mum \
# ../kk010_piston_axi_static_Rn201.5mum_dinit90mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit90mum \
# ../kk010_piston_axi_static_Rn184.1mum_dinit150mum \
# ../kk010_piston_axi_static_Rn201.5mum_dinit150mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit150mum \
# ../kk010_piston_axi_static_Rn184.1mum_dinit30mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit30mum \
# "

study_cases=" \
../kk010_piston_axi_static_Rn184.1mum_dinit250mum_sigma \
../kk010_piston_axi_static_Rn201.5mum_dinit250mum_sigma \
../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
