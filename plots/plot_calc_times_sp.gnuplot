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

set xrange [*:*]
set yrange [0.1:*]
set y2range [0:*]

set tmargin at screen 0.8

a=1
b=3
c=1

f(x) = a/x**b + c

fit [*:*] f(x) "calc_times_sp.dat" u 1:(($2)/60.*($4)/101e-6) via a,b,c

set logscale y

p \
f(x) t sprintf("%.1f /(res.)^{%.1f} + %.1f",a,b,c),\
     "calc_times_sp.dat"  u 1:(($2)/60.*($4)/101e-6) w p ps 2 lw 3 t "times Ryzen 1 thread",\
     "calc_times_sp2.dat" u 1:(($2)/60.*($4)/101e-6) w p ps 2 lw 3 t "times Ryzen 8 threads",\
     "calc_times_sp.dat"  u 1:(($3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t "amount of cells",\
     "calc_times_sp2.dat" u 1:(($3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t ""
