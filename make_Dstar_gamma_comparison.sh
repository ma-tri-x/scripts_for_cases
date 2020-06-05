#!/bin/bash

thisdir=$(pwd)
echo "#dstar    Rmax" > Rmax_of_dstar.dat
for i in ../dstar_*;do
    cd $i
    #cp ../dstar/get_Rmax_by_THETA.py .
    Rmax=$(python get_Rmax_by_THETA.py)
    echo "${i#../dstar_}    $Rmax" >> $thisdir/Rmax_of_dstar.dat
    cd $thisdir
done

gnuplot plot_Dstar_gamma_comparison.gnuplot
epstopdf Dstar_gamma_comparison.eps
pdfcrop Dstar_gamma_comparison.pdf Dstar_gamma_comparison.pdf
rm Dstar_gamma_comparison.eps
