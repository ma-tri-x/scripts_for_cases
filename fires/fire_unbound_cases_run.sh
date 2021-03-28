#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}

unbound_cases=" \
../kk010_piston_axi_static_unbound_Rn184mum \
../kk010_piston_axi_static_unbound_Rn201mum \
../kk010_piston_axi_static_unbound_Rn240mum \
"

for i in $unbound_cases;do
    cd $i
    fire
    cd $thisdir
done
