#!/bin/gnuplot
reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Dstar_gamma_comparison.eps"

#set term wxt
#set output

set key top left

set grid xtics mxtics ytics mytics lw 2, lw 1
set xlabel "D^*"
set ylabel "{/Symbol g}_d"
set size ratio -1
set xtics 0.5
set ytics 0.5
set mxtics 5
set mytics 5

a=1.0
b=1
c=0.6

f(x) = a*(x)+b
fit f(x) "Rmax_ydist_of_dstar.dat" u ($1):(($3)/($2)) via a,b

system(sprintf("echo \"%f \\* x + %f\" > formula.info",a,b))

p [0:2] \
        f(x) t sprintf("%.3f * (D^*) + {%.3f}",a,b),\
        "Rmax_ydist_of_dstar.dat" u ($1):(($3)/($2)) w p ps 2 lw 2 t "simulated"
