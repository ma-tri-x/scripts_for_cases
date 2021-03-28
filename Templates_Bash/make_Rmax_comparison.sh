#!/bin/bash

thisdir=$(pwd)
echo "#cellSize    Rmax    relRmax_to_1mum    theta    initial_volume    initial_pressure" > Rmax.dat
Rmax1mum=$(python get_Rmax_by_THETA.py)
for i in ../0071_dstar1.6_from_sose2019_boxBubble*;do
    cd $i
    if [ ! $i == "../0071_dstar1.6_from_sose2019_boxBubble" ];then
        cp ../0071_dstar1.6_from_sose2019_boxBubble/get_Rmax_by_THETA.py .
        cp ../0071_dstar1.6_from_sose2019_boxBubble/get_max_p_t0.py .
    fi
    getV=($(head -n 2 postProcessing/volumeIntegrate_volumeIntegral/0/alpha2 | tail -n 1))
    V0=${getV[1]}
    p0=$(python get_max_p_t0.py)
    Rmax=$(python get_Rmax_by_THETA.py)
    Rmaxrel=$(m4 <<< "esyscmd(perl -e 'printf (   ${Rmax}/${Rmax1mum}  )')")
    theta=$(cat THETA)
    echo "$(python getparm.py -s mesh -q cellSize)    $Rmax    $Rmaxrel   $theta   $V0    $p0" >> ../0071_dstar1.6_from_sose2019_boxBubble/Rmax.dat
    cd $thisdir
done

gnuplot plot_initial_pVgamma.gnuplot
epstopdf initial_pVgamma.eps
pdfcrop initial_pVgamma.pdf initial_pVgamma.pdf
rm initial_pVgamma.eps
