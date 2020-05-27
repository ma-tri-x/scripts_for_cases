#!/bin/gnuplot

reset
set term postscript eps color enhance solid font "DejaVuSerif, 18"
set output "calc_times.eps"

set grid

set xlabel "res. [{/Symbol m}m]"
set ylabel "calc. time [min]"

set xrange [0.7:5]

a=3400./60.
b=3

f(x) = a/x**b

fit f(x) "calc_times.dat" u 1:(($2)/60.) via a,b

set logscale y

p f(x) t sprintf("%.1f /(res.)^{%.1f}",a,b),\
  "calc_times.dat" u 1:(($2)/60.) w p ps 2 lw 3 t "calculation times"
