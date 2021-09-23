#!/bin/bash

thisdir=$(pwd)

postproc_dir=RESULTS
mkdir -p $postproc_dir

summary=jet_velocities_summary.dat


# cases=*Rn*dinit*

cases="Rn175.50_dinit90 
Rn191.61_dinit250
Rn191.61_dinit350
rpstar0.65_dstar1_Rn158.80_dinit419.69
rpstar0.65_dstar2_Rn158.80_dinit839.38  
rpstar0.65_dstar3_Rn158.80_dinit1259.08 
rpstar0.65_dstar4_Rn158.80_dinit1678.77 
rpstar0.65_dstar6_Rn158.80_dinit2518.15
rpstar0.75_dstar2_Rn141.13_dinit727.47
rpstar0.95_dstar3_Rn116.94_dinit861.47
"

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
    echo "" > $summary
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
    echo "keeping dats and pdfs then... exit`"
fi
