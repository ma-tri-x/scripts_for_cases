#!/bin/bash

thisdir=$(pwd)

get_dstar () {
dir=$1
python <<< "print(\"${dir}\".split(\"dstar_\")[-1].split(\"_\")[0])"
}

study_cases="
../dstar_0.2 \
"
for i in $study_cases
do
    dstar=$(get_dstar $i)
    j=${i}_probed
    echo $j
    if [ -d $j/scripts_repo ];then rm -rf $j/scripts_repo;fi
    bash cp_toNewProject.sh $j
    cd $j
    dinit=$(python <<< "print($dstar * 495e-6)")
    sed -i "s/\"D_init\":.*/\"D_init\": $dinit,/g" conf_dict.json
    cp Allrun.template.Econst.RnChangeFromAllrun.ProbePrgh Allrun.template
    rm Allrun.template.*
    bash rerun.sh -par
    cd $thisdir
#     exit 0
done
