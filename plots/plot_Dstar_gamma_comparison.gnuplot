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
b=2
c=0.6

f(x) = a*(x)**b+c
fit f(x) "Rmax_ydist_of_dstar.dat" u ($1):(($3)/($2)) via a,b,c

p [0:2] \
        f(x) t sprintf("%.3f * (D^*)^{%.3f} + %.3f",a,b,c),\
        "Rmax_ydist_of_dstar.dat" u ($1):(($3)/($2)) w p ps 2 lw 2 t "simulated"
