#!/bin/bash

thisdir=$(pwd)

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}
# 
# get_dinit ()
# {
#     echo "$(python <<< "print(\"${1}\".split(\"dinit\")[-1].split(\"mum\")[0])")"
# }

# ../conv_study_3mum_Econst \
# ../conv_study_2mum_Econst \
# ../conv_study_1.35mum_Econst \
# ../conv_study_1.2mum_Econst \
# ../conv_study_1mum_Econst \
# ../conv_study_0.75mum_Econst \
# ../conv_study_0.65mum_Econst_wp14 \
# ../conv_study_0.5mum_Econst_wp14 \

# ../conv_study_3mum_Econst_RnChange \
# ../conv_study_2mum_Econst_RnChange \
# ../conv_study_1.35mum_Econst_RnChange \
# ../conv_study_1.2mum_Econst_RnChange \
# ../conv_study_1mum_Econst_RnChange \
# ../conv_study_0.75mum_Econst_RnChange \
# ../conv_study_2mum_Econst_RnChange_maxCo0.1 \
# ../conv_study_2mum_Econst_RnChange_stbAc09 \
# ../conv_study_0.6mum_Econst_RnChange_stbAc09 \

# ../conv_study_1.2mum_Econst_RnChange_maxCo0.1 \
study_cases=" \
../conv_study_3mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_2mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_1.35mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_1mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
"

for i in $study_cases;do
    cellSize="$(get_dx $i)e-6"
    echo $cellSize
    bash cp_toNewProject.sh $i
    cd $i
    sed -i "s/\"cellSize\".*: .*,/\"cellSize\" : ${cellSize},/g" conf_dict.json
    sed -i "s/\"maxCo\".*: .*,/\"maxCo\" : 0.2,/g" conf_dict.json
    sed -i "s/\"maxAlphaCo\".*: .*,/\"maxAlphaCo\" : 0.08,/g" conf_dict.json
    sed -i "s/startFrom.*;/startFrom    startTime;/g" system/controlDict.template
    sed -i "s/writePrecision.*;/writePrecision    14;/g" system/controlDict.template
    sed -i "s/\"tTransitStart\".*: .*,/\"tTransitStart\" : 60e-6,/g" conf_dict.json
    cp Allrun.template.Econst.RnChange Allrun.template
    rm Allrun.template.Econst
    echo "creating $i"
    bash rerun.sh -par
    Rn=$(cat Rn_export)
    sed -i "s/ Rn.* Rn.*;/ Rn                 Rn    [0 1 0 0 0 0 0] ${Rn};/g" constant/transportProperties
    cd $thisdir
done
