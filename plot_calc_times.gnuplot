#!/bin/gnuplot

reset
set term postscript eps color enhance solid font "DejaVuSerif, 18"
set output "calc_times.eps"

set grid

set xlabel "res. [{/Symbol m}m]"
set ylabel "calc. time [hours]"

set xrange [*:*]

a=3400./60./60.
b=4.6
c=0.05

f(x) = a/x**b + c

fit f(x) "calc_times.dat" u 1:(($2)/60./60.) via a,b

set logscale y

p f(x) t sprintf("%.1f /(res.)^{%.1f} + %.2f",a,b,c),\
  "calc_times.dat" u 1:(($2)/60./60.) w p ps 2 lw 3 t "calculation times"
