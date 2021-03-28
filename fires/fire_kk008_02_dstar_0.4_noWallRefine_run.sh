#!/bin/bash

thisdir=$(pwd)

fire ()
{
    echo "fire!!! $(basename $(pwd))"
    logfile=run.log
    i=2
    while [ -e $logfile ];do
        logfile="run${i}.log"
        let 'i=i+1'
    done
    mpirun -np 16 localMassCorr_working_f0f82d3 -parallel > $logfile 2>&1
}


# ../dstar_0.2 \
# ../dstar_0.6 \
# ../dstar_0.8 \
# ../dstar_1.0 \
# ../dstar_1.2 \
# ../dstar_1.4 \
# ../dstar_1.6 \
# ../dstar_1.8 \
# ../noWallRefine_dstar_0.4 \
# dstar_cases=" \
# ../noWallRefine_dstar_0.42 \
# "
dstar_cases=" \
../noWallRefine_dstar_0.4_tTransitStart90mus \
"

for dstar in $dstar_cases;do
    cp change_control_dict_deamon.py $dstar
    cp change_controlDict_0.4_noWallRefine.json $dstar/change_controlDict.json
    cd $dstar
    sed -i "s/startFrom.*;/startFrom    latestTime;/g" system/controlDict
    python change_control_dict_deamon.py > log.change_control_dict_deamon  &
#     curtime=$(python find_biggestNumber.py -p processor0)
#     endtime=$(python getparm.py -q "endTime" -s "controlDict")
# 
#     ct=`printf "%.12f" $curtime`
#     et=`printf "%.12f" $endtime`
# 
#     echo $dstar
#     if [[ $curtime == "0.0" ]];then
#         mpirun -np 16 localMassCorr_working -parallel > run.log 2>&1
#     elif [ $(echo "$et > $ct" | bc -l) == 1  ]; then 
#         mpirun -np 16 localMassCorr_working -parallel >> run2.log 2>&1
#     fi
    fire
    touch stop_deamon
    cd $thisdir
done
