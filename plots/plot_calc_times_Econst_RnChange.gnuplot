#!/bin/gnuplot

reset
set term postscript eps color enhance solid font "DejaVuSerif, 22"
set output "calc_times.eps"

set grid
set key above

#set title TITLE

set xlabel "res. [{/Symbol m}m]"
set ylabel "calc. time [min]"
set y2label "amount of cells [10^3]"

set y2tics nomirror
set ytics nomirror

set xrange [0.45:3.2]
set yrange [1:10000]
set y2range [0:450]

set tmargin at screen 0.8

a=3400./60.
b=3
c=1

f(x) = a/x**b + c

fit [0.4:*] f(x) "calc_times3.dat" u 1:(($2)/60.*101e-6/($4)) via a,b

set logscale y

p \
f(x) t sprintf("%.1f /(res.)^{%.1f} + %.1f",a,b,c),\
     "calc_times3.dat"  u 1:(($2)/60.*101e-6/($4)) w p ps 2 lw 3 t "times Ryzen",\
     "calc_times3.dat"  u 1:(($3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t "amount of cells"
