#!/bin/bash

thisdir=$(pwd)

if [ ! $# == 1 ];then
    echo "usage: $0 <case_dir>"
    exit 1
fi

case_dir=$1

fitlogs_dir=$case_dir/fit_logs

mkdir -p $fitlogs_dir

if [ ! -e $case_dir/contours/contours0.0.csv ]
then
    echo -e "ERROR: $case_dir/contours/contours0.0.csv\nno such file or directory"
    exit 1
fi

# params="
# a
# b
# c
# "

plot_script=fit_modes.gnuplot

startNUM=0 
NUMS=$(python3 helper_fit_modes_sortTsteps.py $case_dir/contours/ $startNUM)

rm $fitlogs_dir/*.jpeg $fitlogs_dir/*.log

for NUM in $NUMS
do
    contour=$case_dir/contours/contours0.$NUM.csv
    fit_script=fit_modes_symm_V2.gnuplot.backup
    cp $fit_script $plot_script
    sed -i "s#Rn164.3_20kHz_0.8/test0.csv#$contour#g" $plot_script
    gnuplot $plot_script > /dev/null 2>&1
    ErrorCount=$(python3 helper_fit_modes_countBigError.py)
    ErrorSize=$(python3 helper_fit_modes_reportBigError.py)
    echo -e "$case_dir, ts=$NUM, $ErrorSize %"
    fit_type=${fit_script%.gnuplot.backup}
    fit_type=${fit_type#fit_modes_}
    mv bla.jpeg $fitlogs_dir/fit_$(printf "%03d" $NUM)_$fit_type.jpeg
    cp fit.log $fitlogs_dir/fit.$NUM.log
    
    if [ $ErrorCount == "breakup" ]
    then
        echo "breakup"
        break
    fi
done
