#!/bin/bash

thisdir=$(pwd)

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

study_cases=" \
../sp_conv_study_3mum_int3cells_XF100 \
../sp_conv_study_2mum_int3cells_XF100 \
../sp_conv_study_1.35mum_int3cells_XF100 \
../sp_conv_study_1mum_int3cells_XF100 \
../sp_conv_study_0.6mum_int3cells_XF100 \
../sp_conv_study_0.4mum_int3cells_XF100 \
"
# ../sp_conv_study_0.1mum \
# ../sp_conv_study_0.05mum \
# ../sp_conv_study_0.02mum \
# ../sp_conv_study_0.2mum \

for i in $study_cases;do
    cellSize="$(get_dx $i)e-6"
    echo $cellSize
    widthInt=$(m4 <<< "esyscmd(perl -e 'printf ( 3*$cellSize )')")
    bash cp_toNewProject.sh $i
    cd $i
    sed -i "s/\"cellSize\".*: .*,/\"cellSize\" : ${cellSize},/g" conf_dict.json
    sed -i "s/\"maxCo\".*: .*,/\"maxCo\" : 0.2,/g" conf_dict.json
    sed -i "s/\"maxAlphaCo\".*: .*,/\"maxAlphaCo\" : 0.08,/g" conf_dict.json
#     sed -i "s/startFrom.*;/startFrom    startTime;/g" system/controlDict.template
#     sed -i "s/writePrecision.*;/writePrecision    14;/g" system/controlDict.template
    sed -i "s/\"tTransitStart\".*: .*,/\"tTransitStart\" : 60e-6,/g" conf_dict.json
    sed -i "s/\"meshFile\".*: .*,/\"meshFile\" : \"spherical_plus_core_writeTheta.m4\",/g" conf_dict.json
    sed -i "s/\"D_init\".*: .*,/\"D_init\" : 0.0,/g" conf_dict.json
    sed -i "s/\"snappyHexMesh\".*: .*,/\"snappyHexMesh\" : \"false\",/g" conf_dict.json
    sed -i "s/\"stitchMesh\".*: .*,/\"stitchMesh\" : \"false\",/g" conf_dict.json
    sed -i "s/\"meshDims\".*: .*,/\"meshDims\" : \"1D\",/g" conf_dict.json
    sed -i "s/\"widthOfInterface\".*: .*,/\"widthOfInterface\" : $widthInt ,/g" conf_dict.json
    sed -i "s/\"domainSizeFactorRmax\".*: .*,/\"domainSizeFactorRmax\" : 100,/g" conf_dict.json
    # decompose was off down to 0.2mum
    sed -i "s/\"decompose\": \"true\"/\"decompose\": \"false\"/g" conf_dict.json
    #sed -i "s/\"xyz\": \"8 2 1\",/\"xyz\": \"8 1 1\",/g"  conf_dict.json
    #sed -i "s/\"threads\": 16,/\"threads\": 8,/g" conf_dict.json
    #sed -i "s/\"method\": \"metis\",/\"method\": \"simple\",/g" conf_dict.json
    cp Allrun.template.spherical Allrun.template
    cp system/controlDict_spherical.template system/controlDict.template
    rm Allrun.template.*
    echo "creating $i"
    bash rerun.sh -par
    Rn=$(cat Rn_export)
    sed -i "s/ Rn.* Rn.*;/ Rn                 Rn    [0 1 0 0 0 0 0] ${Rn};/g" constant/transportProperties
    cd $thisdir
done

for i in $study_cases;do
    echo $i
    cat $i/conf_dict.json | grep "\"domainSizeFactorRmax\""
done
