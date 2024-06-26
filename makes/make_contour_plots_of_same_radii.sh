#!/bin/bash

thisdir=$(pwd)

radii="220e-6 160e-6 120e-6"
keyIn="120e-6"
start_time="80e-6"

echo "NOTE: if somewhere/contour/*.csv are missing"
echo "      then execute once"
echo "         python render_2D_contours.py"
echo "         python merge_split_files.py"
echo "      in the dir where they are missing"

i=1
for radius in $radii
do
    cp plot_contour_at_radius.gnuplot.backup plot_contour.gnuplot
    if [ $i == 1 ]
    then
        sed -i "s/1STNOCOMMENT//g" plot_contour.gnuplot
        sed -i "s/1STCOMMENT/#/g" plot_contour.gnuplot
    else
        sed -i "s/1STNOCOMMENT/#/g" plot_contour.gnuplot
        sed -i "s/1STCOMMENT//g" plot_contour.gnuplot
    fi
    if [ $radius == $keyIn ]
    then
        sed -i "s/UNCOMMENTFORKEY//g" plot_contour.gnuplot
        sed -i "s/UNCOMMENTFORNOKEY/#/g" plot_contour.gnuplot
        echo "plotting key"
    else
        sed -i "s/UNCOMMENTFORKEY/#/g" plot_contour.gnuplot
        sed -i "s/UNCOMMENTFORNOKEY//g" plot_contour.gnuplot
    fi
    gnuplot -e "radius=$radius ; start_time=$start_time" plot_contour.gnuplot
#     epstopdf contour.eps
#     rm contour.eps
#     pdfcrop contour.pdf contour.pdf
#     pdf270 contour.pdf
#     mv contour-rotated270.pdf contour_${radius}_radius.pdf
    cp contour.png contour_${radius}_radius.png
#     rm contour.pdf
    let 'i=i+1'
done

for radius in $radii;do
    convert contour.png contour_${radius}_radius.png -background white -gravity center -compose dstover -composite contour.png
done

convert contour.png -background white -flatten contour.jpg
rm contour*.png

