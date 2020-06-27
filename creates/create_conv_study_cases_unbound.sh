#!/bin/bash

thisdir=$(pwd)

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

study_cases=" \
../conv_study_3mum_unbound_int3cells \
../conv_study_2mum_unbound_int3cells \
../conv_study_1.35mum_unbound_int3cells \
../conv_study_1mum_unbound_int3cells \
../conv_study_0.75mum_unbound_int3cells \
"

for i in $study_cases;do
    cellSize="$(get_dx $i)e-6"
    widthInt=$(m4 <<< "esyscmd(perl -e 'printf ( 3*$cellSize )')")
    echo $cellSize
    bash cp_toNewProject.sh $i
    cd $i
    sed -i "s/\"cellSize\".*: .*,/\"cellSize\" : ${cellSize},/g" conf_dict.json
    sed -i "s/\"maxCo\".*: .*,/\"maxCo\" : 0.2,/g" conf_dict.json
    sed -i "s/\"maxAlphaCo\".*: .*,/\"maxAlphaCo\" : 0.08,/g" conf_dict.json
    sed -i "s/\"tTransitStart\".*: .*,/\"tTransitStart\" : 60e-6,/g" conf_dict.json
    sed -i "s/\"snappyHexMesh\".*: .*,/\"snappyHexMesh\" : \"false\",/g" conf_dict.json
    sed -i "s/\"widthOfInterface\".*: .*,/\"widthOfInterface\" : $widthInt ,/g" conf_dict.json
    sed -i "s/startFrom.*;/startFrom    startTime;/g" system/controlDict.template
    sed -i "s/writePrecision.*;/writePrecision    14;/g" system/controlDict.template
    cp Allrun.template.Econst.RnChange Allrun.template
    rm Allrun.template.*
    echo "creating $i"
    bash rerun.sh -par
    Rn=$(cat Rn_export)
    sed -i "s/ Rn.* Rn.*;/ Rn                 Rn    [0 1 0 0 0 0 0] ${Rn};/g" constant/transportProperties
    cd $thisdir
done
