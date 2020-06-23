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

# ../conv_study_0.75mum_Econst \

# ../conv_study_3mum_Econst \
# ../conv_study_2mum_Econst \
# ../conv_study_1.35mum_Econst \
# ../conv_study_1.2mum_Econst \
# ../conv_study_1mum_Econst \
# ../conv_study_0.65mum_Econst_wp14 \

study_cases=" \
../conv_study_0.5mum_Econst_wp14 \
"

for i in $study_cases;do
    cellSize="$(get_dx $i)e-6"
    echo $cellSize
    bash cp_toNewProject.sh $i
    cd $i
    sed -i "s/\"cellSize\".*: .*,/\"cellSize\" : ${cellSize},/g" conf_dict.json
    sed -i "s/startFrom.*;/startFrom    startTime;/g" system/controlDict.template
    sed -i "s/writePrecision.*;/writePrecision    14;/g" system/controlDict.template
    cp Allrun.template.Econst Allrun.template
    echo "creating $i"
    bash rerun.sh -par
    cd $thisdir
done
