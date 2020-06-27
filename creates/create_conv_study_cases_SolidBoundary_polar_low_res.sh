#!/bin/bash

thisdir=$(pwd)

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

study_cases=" \
../conv_study_3mum_SolidBoundary_polar_low_res \
../conv_study_2mum_SolidBoundary_polar_low_res \
../conv_study_1.35mum_SolidBoundary_polar_low_res \
../conv_study_1mum_SolidBoundary_polar_low_res \
../conv_study_0.75mum_SolidBoundary_polar_low_res \
"

for i in $study_cases;do
    cellSize="$(get_dx $i)e-6"
#     refineDistsOrig="60 15 9 6 3 2 1 0.8 0.5 0.2" # $(python getparm.py -s refine -q refDistsInRmax)
#     refineDists="2" #"55 15 9 6 3 2 1 0.8 0.5 0.2"
#     n=0
#     for k in $refineDists;do n=`expr $n + 1`;done
#     refineTimes=$n
#     cellSize=$(m4 <<< "esyscmd(perl -e 'printf ( 2**${refineTimes}*$cellSize )')")
    if [ -d $i ];then rm -rf $i/scripts_repo;fi
    bash cp_toNewProject.sh $i
    echo "max cellSize: $cellSize"
    cd $i
    #Rmax=$(python getparm.py -s bubble -q Rmax)
    #fact=$(python getparm.py -s mesh -q domainSizeFactorRmax)
    #refineUntil=$(m4 <<< "esyscmd(perl -e 'printf ( $Rmax * $fact * 0.15 )')")
    sed -i "s/\"cellSize\".*: .*,/\"cellSize\" : ${cellSize},/g" conf_dict.json
    sed -i "s/\"maxCo\".*: .*,/\"maxCo\" : 0.2,/g" conf_dict.json
    sed -i "s/\"maxAlphaCo\".*: .*,/\"maxAlphaCo\" : 0.2,/g" conf_dict.json
    sed -i "s/\"tTransitStart\".*: .*,/\"tTransitStart\" : 60e-6,/g" conf_dict.json
    sed -i "s/\"domainSizeFactorRmax\".*: .*,/\"domainSizeFactorRmax\" : 100,/g" conf_dict.json
    sed -i "s/\"FactorBubbleDomainRmax\".*: .*,/\"FactorBubbleDomainRmax\" : 1.05,/g" conf_dict.json
    sed -i "s/\"meshCoreSize\":.*,/\"meshCoreSize\": 50e-6,/g" conf_dict.json
    sed -i "s/\"gradingFactor\".*/\"gradingFactor\": 5.2/g" conf_dict.json
    #sed -i "s/\"refineWall\": .*,/\"refineWall\": \"true\",/g" conf_dict.json
    #sed -i "s/\"wallRefineHeight\".*,/\"wallRefineHeight\": -690e-6,/g" conf_dict.json
    sed -i "s/\"meshFile\": .*,/\"meshFile\": \"blockMeshDict_axisymm_coreCart_reg_unbound_writeTheta_V2.m4\",/g" conf_dict.json
    #sed -i "s/\"snappyHexMesh\".*: .*,/\"snappyHexMesh\" : \"true\",/g" conf_dict.json
    #sed -i "s/\"makeAxialMesh\".*: .*,/\"makeAxialMesh\" : \"false\",/g" conf_dict.json
    #sed -i "s/\"stitchMesh\".*: .*,/\"stitchMesh\" : \"false\",/g" conf_dict.json
    #sed -i "s/\"refineMesh\": .*,/\"refineMesh\": \"true\",/g" conf_dict.json
    #sed -i "s/\"refineTimes\".*: .*,/\"refineTimes\": ${refineTimes},/g" conf_dict.json
    #sed -i "s/\"refineFrom\".*: .*,/\"refineFrom\": 60e-6,/g" conf_dict.json
    #sed -i "s/\"refineUntil\".*: .*,/\"refineUntil\": ${refineUntil},/g" conf_dict.json
    ##refDistsInRmax:
    #sed -i "s/${refineDistsOrig}/${refineDists}/g" conf_dict.json
    #sed -i "s/\"FactorBubbleDomainRmax\": 1.2,/\"FactorBubbleDomainRmax\": 0.2,/g" conf_dict.json
    #cp system/controlDict_spherical.template system/controlDict.template
    sed -i "s/startFrom.*;/startFrom    startTime;/g" system/controlDict.template
    sed -i "s/writePrecision.*;/writePrecision    14;/g" system/controlDict.template
    #sed -i "s/-_BUBBLE-D_INIT/0.0/g" system/controlDict.template
    cp Allrun.template.SolidBoundary_SOMEOTHER Allrun.template
    rm Allrun.template.*
    echo "creating $i"
    bash rerun.sh -par
    Rn=$(cat Rn_export)
    sed -i "s/ Rn.* Rn.*;/ Rn                 Rn    [0 1 0 0 0 0 0] ${Rn};/g" constant/transportProperties
    cd $thisdir
#     exit 0
done
