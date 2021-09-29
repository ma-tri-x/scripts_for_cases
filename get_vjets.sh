#!/bin/bash

thisdir=$(pwd)

postproc_dir=RESULTS
mkdir -p $postproc_dir

summary=jet_velocities_summary.dat


# cases=*Rn*dinit*
# cases="
# Rn175.50_dinit30
# "
# Rn175.50_dinit150
# rpstar0.65_dstar2_Rn158.80_dinit839.38  
# Rn97.00_dinit30
# rpstar1.05_dstar1_Rn108.30_dinit259.81
cases="Rn227.25_dinit30
Rn227.25_dinit90
Rn227.25_dinit150
Rn227.25_dinit250
Rn227.25_dinit350
Rn227.25_dinit400
Rn227.25_dinit450
"

echo "Do you want to backup and erase $summary ? [y/n]:"
read bla

if [ $bla == "y" ]
then
    i=0
    while [ -e ${summary}.backup${i} ]
    do
        let 'i=i+1'
    done
    cp $summary ${summary}.backup$i
    echo "" > $summary
fi


for casedir in $cases
do
    if [ -d $casedir ]
    then
        echo $casedir
        python3 vjet.py $casedir
    fi
done

echo "Satisfied with all your jets processings? [y/n]:"
read bla

if [ $bla == "y" ]
then
    echo "copying pdfs to cases and to RESULTS..."
    echo "copying dats to RESULTS..."
    echo "summarizing dats into $summary ..."
    for casedir in $cases
    do
        if [ -d $casedir ]
        then
            cp ${casedir}.pdf ${casedir}/contour/
            cat ${casedir}.dat >> $summary
            
            mv ${casedir}.pdf ${postproc_dir}/pdf
            mv ${casedir}.dat ${postproc_dir}/dat
        fi
    done
else
    echo "keeping dats and pdfs then... exit"
fi
