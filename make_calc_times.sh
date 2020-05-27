#!/bin/bash

thisdir=$(pwd)

casename=$(python <<< "print(\"${thisdir}\".split(\"/\")[-1])")
echo "#cellsize  exec_time  number_of_cells" > calc_times.dat
for i in ../${casename}*;do
    echo $i
    cd $i
#     cs=$(python <<< "$(python getparm.py -q cellSize -s mesh)*1e6")
    cs=$(m4 <<< "esyscmd(perl -e 'printf (  $(python getparm.py -q cellSize -s mesh)*1e6  )')")
    exec_time=$(tail -n 60 run.log | grep Exec | tail -n 1 | sed "s/ExecutionTime = //g" | sed "s/ s//g")
    nc=$(grep nCells log.blockMesh | sed "s/  nCells: //g")
    if [[ ! $exec_time == "" ]];then
       echo "$cs  $exec_time  $nc" >> $thisdir/calc_times.dat
    fi
    cd $thisdir
done
# echo "calc_times2.dat still needs to be altered manually"

gnuplot plot_calc_times.gnuplot
epstopdf calc_times.eps
rm calc_times.eps
pdfcrop calc_times.pdf calc_times.pdf
