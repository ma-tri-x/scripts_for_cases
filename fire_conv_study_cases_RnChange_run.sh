#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1
}


# ../conv_study_3mum_Econst_RnChange \
# ../conv_study_2mum_Econst_RnChange \
# ../conv_study_1.35mum_Econst_RnChange \
# ../conv_study_1.2mum_Econst_RnChange \
# ../conv_study_1mum_Econst_RnChange \
# ../conv_study_0.75mum_Econst_RnChange \
# ../conv_study_2mum_Econst_RnChange_maxCo0.1
# ../conv_study_2mum_Econst_RnChange_stbAc09 \
# ../conv_study_0.6mum_Econst_RnChange_stbAc09 \
# ../conv_study_3mum_Econst_RnChange_maxCo0.1 \
# ../conv_study_2mum_Econst_RnChange_maxCo0.1 \
# ../conv_study_1.35mum_Econst_RnChange_maxCo0.1 \
# ../conv_study_1.2mum_Econst_RnChange_maxCo0.1 \
# ../conv_study_1mum_Econst_RnChange_maxCo0.1 \
study_cases=" \
../conv_study_3mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_2mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_1.35mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_1mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
"

for i in $study_cases;do
    cd $i
    fire
    cd $thisdir
done
