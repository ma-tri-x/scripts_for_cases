#!/bin/gnuplot

reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Rmax.eps"

set grid
set y2tics

set ylabel "R_{max} [{/Symbol m}m]"
set xlabel "grid resolution [{/Symbol m}m]"
set y2label "R_{max}/R_{max}|_{1{/Symbol m}m}" textcolor lt 2

Rmax1mum=system("python get_Rmax_by_THETA.py")*1e6

set xrange [0.5:4.5]
set yrange [480:494]
set y2range [480./Rmax1mum:494/Rmax1mum]

p "Rmax.dat" u (($1)*1e6):(($2)*1e6)  notitle,\
  ""         u (($1)*1e6):3 axis x1y2 notitle
