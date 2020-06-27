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


echo "using first line of vortices_simulated.dat to select formula"
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
sed -i "s/ADDPLOT/\"vortices_simulated.dat\" u (dstar_to_gamma(\$1)):2 w p lc 2 pt 2 ps 3 t \"simulated\"/g" $plotfile
gnuplot $plotfile
epstopdf fabians_diagramm.eps
pdfcrop fabians_diagramm.pdf fabians_diagramm_$formula.pdf
rm fabians_diagramm.eps fabians_diagramm.pdf 
