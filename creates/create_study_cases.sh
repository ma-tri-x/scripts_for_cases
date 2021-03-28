#!/bin/bash

thisdir=$(pwd)

get_Rn ()
{
    echo "$(python <<< "print(\"${1}\".split(\"Rn\")[-1].split(\"mum\")[0])")"
}

get_dinit ()
{
    echo "$(python <<< "print(\"${1}\".split(\"dinit\")[-1].split(\"mum\")[0])")"
}

# study_cases=" \
# ../kk010_piston_axi_static_Rn184.1mum_dinit30mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit30mum \
# ../kk010_piston_axi_static_Rn184.1mum_dinit90mum \
# ../kk010_piston_axi_static_Rn201.5mum_dinit90mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit90mum \
# ../kk010_piston_axi_static_Rn184.1mum_dinit150mum \
# ../kk010_piston_axi_static_Rn201.5mum_dinit150mum \
# ../kk010_piston_axi_static_Rn240.0mum_dinit150mum \
# "
study_cases=" \
../kk010_piston_axi_static_Rn184.1mum_dinit250mum_sigma \
../kk010_piston_axi_static_Rn201.5mum_dinit250mum_sigma \
../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma \
"

for i in $study_cases;do
    Rn=$(get_Rn $i)
    dinit=$(get_dinit $i)
    bash cp_toNewProject.sh $i
    cd $i
    sed -i "s/\"D_init\".*: .*,/\"D_init\" : ${dinit}e-6 ,/g" conf_dict.json
    sed -i "s/\"Rn\".*: .*,/\"Rn\" : ${Rn}e-6 ,/g" conf_dict.json
    sed -i "s/\"cellSize\".*: .*,/\"cellSize\" : 1e-6 ,/g" conf_dict.json
    sed -i "s/\"sigma\": .*/\"sigma\": 0.0725/g" conf_dict.json
    sed -i "s/startFrom.*;/startFrom    startTime;/g" system/controlDict.template
    cp Allrun.template.study_cases Allrun.template
    cp system/snappyHexMeshDict.template.study_cases system/snappyHexMeshDict.template
    echo "creating $i"
    bash rerun.sh -par
    cd $thisdir
done
