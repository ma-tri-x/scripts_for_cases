#!/bin/bash

tsteps="194 197 198"

i=1
keyIn="198"
for ts in $tsteps
do
    cp plot_contour.gnuplot.backup plot_contour.gnuplot
    if [ $i == 1 ]
    then
        sed -i "s/1STNOCOMMENT//g" plot_contour.gnuplot
        sed -i "s/1STCOMMENT/#/g" plot_contour.gnuplot
    else
        sed -i "s/1STNOCOMMENT/#/g" plot_contour.gnuplot
        sed -i "s/1STCOMMENT//g" plot_contour.gnuplot
    fi
    if [ $ts == $keyIn ]
    then
        sed -i "s/UNCOMMENTFORKEY//g" plot_contour.gnuplot
        sed -i "s/UNCOMMENTFORNOKEY/#/g" plot_contour.gnuplot
        echo "plotting key"
    else
        sed -i "s/UNCOMMENTFORKEY/#/g" plot_contour.gnuplot
        sed -i "s/UNCOMMENTFORNOKEY//g" plot_contour.gnuplot
    fi
    gnuplot -e "time=$ts" plot_contour.gnuplot
    epstopdf contour.eps
    rm contour.eps
    pdfcrop contour.pdf contour.pdf
    pdf270 contour.pdf
    mv contour-rotated270.pdf contour_${ts}_box.pdf
    rm contour.pdf
    let 'i=i+1'
done
