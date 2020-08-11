#!/bin/bash

thisdir=$(pwd)

get_y_sb () {
line=$(grep "max (1" system/snappyHexMeshDict)
python <<< "print(\"${line}\".split(\"max (1\")[-1].split(\" 1);\")[0])"
}

get_y_sb_plus_offset () {
off=$1
line=$(grep "max (1" system/snappyHexMeshDict)
y_sb=$(python <<< "print(\"${line}\".split(\"max (1\")[-1].split(\" 1);\")[0])")
python <<< "print($y_sb+$off)"
}

get_dstar () {
dir=$1
python <<< "print(\"${dir}\".split(\"dstar_\")[-1].split(\"_\")[0])"
}

# ../dstar_0.0 \
# ../dstar_0.6 \
# ../dstar_0.8 \
# ../dstar_1.0 \
# ../dstar_1.2 \
# ../dstar_1.4 \
# ../dstar_1.6 \
# ../dstar_1.8 \
study_cases="
../dstar_0.1 \
"
# ../noWallRefine_dstar_0.42 \
# ../noWallRefine_dstar_1.30 \
# # ../noWallRefine_dstar_1.29 \
# # ../noWallRefine_dstar_1.31 \
# # ../noWallRefine_dstar_1.32 \
# # ../noWallRefine_dstar_1.33 \
# ../dstar_3.0 \
# ../dstar_3.0_Rn400mu \
# ../dstar_8.0 \

for i in $study_cases
do
    echo $i
    cp $thisdir/scripts_repo/gets/get_closest_timestep.py $i
    cd $i
    j=${i}_probed
    if [ -d $j/scripts_repo ];then rm -rf $j/scripts_repo;fi
    if [ -d $j/processor0 ];then rm -rf $j/proc*;fi
    bash cp_toNewProject.sh $j
    cp $thisdir/controlDict.continueForPressure $j/system/controlDict
    ta=$(python get_closest_timestep.py -p processor0 -t 95e-6)
    off=1.0e-6
    y_sb=$(get_y_sb_plus_offset $off)
    if [[ $i == "../dstar_0.1" ]];then y_sb=$off;fi
    sed -i "s/startTime.*/startTime   ${ta};/g" $j/system/controlDict
    sed -i "s/PROBEX/$off/g" $j/system/controlDict
    sed -i "s/PROBEY/$y_sb/g" $j/system/controlDict
    for p in proc*
    do
        mkdir $j/$p
        cp -r $p/constant $j/$p/
        cp -r $p/$ta $j/$p/
    done
    
    cd $j
        echo "start calc $j from $ta on"
        mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > run.log 2>&1 
    cd $thisdir
#     exit 0
done
