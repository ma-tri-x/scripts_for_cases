#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    logfile=run.log
    i=0
    while [ -e $logfile ];do
        logfile="run${i}.log"
        let 'i=i+1'
    done
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > $logfile 2>&1
}


# dstar_cases=" \
# ../dstar_0.2 \
# ../dstar_0.4 \
# ../dstar_0.6 \
# ../dstar_0.8 \
# ../dstar_1.0 \
# ../dstar_1.2 \
# ../dstar_1.4 \
# ../dstar_1.6 \
# ../dstar_1.8 \
# "

dstar_cases=" \
../noWallRefine_dstar_1.29 \
../noWallRefine_dstar_1.30 \
../noWallRefine_dstar_1.31 \
../noWallRefine_dstar_1.32 \
../noWallRefine_dstar_1.33 \
"

echo "execute change_control_dict_deamon? [y/n]"
read deamon

for dstar in $dstar_cases;do
    if [ $deamon == "y" ]
    then
        cp change_control_dict_deamon.py $dstar
        cp change_controlDict_continue.json $dstar/change_controlDict.json
    fi
    cd $dstar
    sed -i "s/startFrom.*;/startFrom    latestTime;/g" system/controlDict
    sed -i "s/endTime.*;/endTime    1e-3;/g" system/controlDict
    if [ $deamon == "y" ]
    then
        python change_control_dict_deamon.py >> log.change_control_dict_deamon  &
    fi
#     curtime=$(python find_biggestNumber.py -p processor0)
#     endtime=$(python getparm.py -q "endTime" -s "controlDict")
# 
#     ct=`printf "%.12f" $curtime`
#     et=`printf "%.12f" $endtime`

    echo $dstar
    fire
    touch stop_deamon
    cd $thisdir
done
