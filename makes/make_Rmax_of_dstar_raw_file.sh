#!/bin/bash
thisdir=$(pwd)

outfile=Rmax_of_dstar_raw.dat
echo "" > $outfile

for i in ../*dstar_?.?*
do
cd $i
Rmax=$(python get_Rmax_by_THETA.py)
echo "$i   $Rmax" >>  $thisdir/$outfile
cd $thisdir
# exit 0
done
