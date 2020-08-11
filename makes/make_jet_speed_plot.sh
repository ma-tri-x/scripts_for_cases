#!/bin/bash

thisdir=$(pwd)
plotfile=plot_jet_speed.gnuplot

get_fast_jet_speed(){
dir=$1
ta=$2
tb=$3
dstar=$4
cp $thisdir/get_fast_jet_velocity_between_ta_and_tb.py $dir
cd $dir
vjet=$(echo "$(python get_fast_jet_velocity_between_ta_and_tb.py -ta $ta -tb $tb ) *(-1)" | bc )
echo "$dstar   $vjet # $dir"
cd $thisdir
}

outfile=fast_jet_speed.dat
echo "" > $outfile
get_fast_jet_speed ../dstar_0.0 109.25e-6 109.34e-6 0.0 | tee -a $outfile
get_fast_jet_speed ~/Desktop/foamProjects/kk011_dstar0/dinit0_Rn220 133.695e-6 133.805e-6 0.0 | tee -a $outfile
get_fast_jet_speed /storage/BERLIN_STORAGE/2019WiSe2020/foamProjects/b009_3D_highResImpact 113.372e-6 113.572e-6 0.041 | tee -a $outfile
get_fast_jet_speed /storage/BERLIN_STORAGE/2019SoSe/foamProjects/c007_02_3D_param_study_1.9mum 112.302e-6 112.419e-6 0.041 | tee -a $outfile

cp $plotfile.backup $plotfile
gnuplot $plotfile
epstopdf jet_speed.eps
epstopdf jet_speed_fast_jet.eps
epstopdf jet_speed_dstar_3.0.eps
rm *.eps
pdfcrop jet_speed.pdf jet_speed.pdf
pdfcrop jet_speed_fast_jet.pdf jet_speed_fast_jet.pdf
pdfcrop jet_speed_dstar_3.0.pdf jet_speed_dstar_3.0.pdf
