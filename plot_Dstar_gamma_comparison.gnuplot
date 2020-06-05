#!/bin/gnuplot
reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Dstar_gamma_comparison.eps"

#set term wxt
#set output

set key top left

set grid
set xlabel "D^*"
set ylabel "{/Symbol g}"

a=1.0
b=0.001

f(x) = a*x+b
fit f(x) "Rmax_of_dstar.dat" u ($1):(495e-6*($1)/($2)) via a,b

p [0:2] \
        f(x) t sprintf("%.2f  D^* + %.2f",a,b),\
        "Rmax_of_dstar.dat" u ($1):(495e-6*($1)/($2)) w p ps 2 lw 2 t "simulated"
