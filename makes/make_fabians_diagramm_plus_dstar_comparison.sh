#!/bin/bash

thisdir=$(pwd)

plotfile=plot_fabians_diagramm.gnuplot

cp $plotfile.backup $plotfile
sed -i "s/wall vortex\",\\\/wall vortex\"/g" $plotfile
sed -i "s/ADDPLOT//g" $plotfile
gnuplot $plotfile
epstopdf fabians_diagramm.eps
pdfcrop fabians_diagramm.pdf fabians_diagramm_raw.pdf
rm fabians_diagramm.eps fabians_diagramm.pdf

echo "execute make_Dstar_gamma_comparison.sh, too? [y/n]"
read comparison
if [ $comparison == "y" ]
then
    echo "data points boxBubble or sphere init data? [b/s]"
    read boxBubble
    if [ $boxBubble == "b" ]
    then
        study_cases=" \
        ../../kk008_batch_simu_Dstar/dstar_0.2 \
        ../../kk008_batch_simu_Dstar/dstar_0.4 \
        ../../kk008_batch_simu_Dstar/dstar_0.6 \
        ../../kk008_batch_simu_Dstar/dstar_0.8 \
        ../../kk008_batch_simu_Dstar/dstar_1.0 \
        ../../kk008_batch_simu_Dstar/dstar_1.2 \
        ../../kk008_batch_simu_Dstar/dstar_1.4 \
        ../../kk008_batch_simu_Dstar/dstar_1.6 \
        ../../kk008_batch_simu_Dstar/dstar_1.8 \
        "
    elif [ $boxBubble == "s" ]
    then
        study_cases=" \
        ../noWallRefine_dstar_0.4 \
        ../noWallRefine_dstar_0.42 \
        ../dstar_0.6 \
        ../dstar_0.8 \
        ../dstar_1.0 \
        ../dstar_1.2 \
        ../noWallRefine_dstar_1.29 \
        ../noWallRefine_dstar_1.30 \
        ../noWallRefine_dstar_1.31 \
        ../noWallRefine_dstar_1.32 \
        ../noWallRefine_dstar_1.33 \
        ../dstar_1.4 \
        ../dstar_1.6 \
        ../dstar_1.8 \
        "
    fi
    bash make_Dstar_gamma_comparison.sh $study_cases
fi
    

echo "using first line of Rmax_ydist_of_dstar.dat to select formula"
formula=$(head -n 1 Rmax_ydist_of_dstar.dat | sed "s/#//g")

cp $plotfile.backup $plotfile

if [ $formula == "Rmaxv_ydistc10e-6" ]
then
    sed -i "s/#FUNC/dstar_to_gamma(x)=0.689681\*x\*\*1.28703+0.362228/g" $plotfile
elif [ $formula == "Rmaxv_ydistd" ]
then
    sed -i "s/#FUNC/dstar_to_gamma(x)=1.01247\*x+0.00918621/g" $plotfile
else
    echo "ERROR: formula not implemented"
    exit 1
fi

outfile=fabians_diagramm_${formula}_$boxBubble.pdf
opts="w p lc 4 pt 6 ps 3"
if [ $boxBubble == "b" ]
then
    opts="w p lc 8 pt 4 ps 3"
    datafile=vortices_simulated_kk008.dat
elif [ $boxBubble == "s" ]
then
    datafile=vortices_simulated_kk008_02.dat
else
    echo "ERROR: not implemented"
    exit 1
fi
sed -i "s/ADDPLOT/\"${datafile}\" u (dstar_to_gamma(\$1)):2 $opts t \"simulated\"/g" $plotfile
gnuplot $plotfile
epstopdf fabians_diagramm.eps
pdfcrop fabians_diagramm.pdf $outfile
rm fabians_diagramm.eps fabians_diagramm.pdf
evince $outfile
