#!/bin/gnuplot

reset
set term x11
set output

set grid
set xlabel "path [cm]"
set ylabel "photodiode voltage [mV]"
set title "profile of the METTLE flash"

p "METTLE_raw.dat" w lp t "METTLE"

pause -1 "hit enter"

set term postscript eps color enhanced solid
set output "METTLE_raw.eps"
replot
!epstopdf METTLE_raw.eps
!rm *.eps