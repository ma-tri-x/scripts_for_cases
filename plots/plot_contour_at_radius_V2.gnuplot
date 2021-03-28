#!/bin/gnuplot

reset
#set term wxt
#set output

set term pngcairo transparent font "DejaVuSerif, 18pt" size 1000,1000 #postscript enhanced solid color font "DejaVuSerif, 18pt"
set output "contour.png" #"contour.eps"
# UNCOMMENTFORKEY set key above #top left
# UNCOMMENTFORNOKEY unset key
set key above
set size ratio -1
set tics out
set grid lw 3
set datafile separator ","



#autofreq start,incr:
#1STNOCOMMENT set ylabel "y [{/Symbol m}m]"
#1STNOCOMMENT set xlabel "x [{/Symbol m}m]"
#1STNOCOMMENT set xtics autofreq 100
#1STNOCOMMENT set ytics autofreq 100
set ylabel "y [{/Symbol m}m]"
set xlabel "x [{/Symbol m}m]"
set xtics autofreq 100
set ytics autofreq 100

#1STCOMMENT set xtics autofreq 0,100 
#1STCOMMENT unset ylabel
#1STCOMMENT unset xlabel
#1STCOMMENT set format y ""

set xrange [-300:300]
set yrange [-300:300]

plot \
"../dstar_1.6/contour/bla0.22.csv" u ( ($2)*1e6):(($3)*1e6) w l lw 7 lc 7 t "sphere start 1{/Symbol m}m",\
"../dstar_1.6/contour/bla0.22.csv" u (-($2)*1e6):(($3)*1e6) w l lw 7 lc 7 t "",\
"../../kk008_batch_simu_Dstar/dstar_1.6/contour/bla0.17.csv" u ( ($2)*1e6):(($3)*1e6) w l lw 3 lc rgbcolor "0x0000FF" dt 1 t "box start 2{/Symbol m}m",\
"../../kk008_batch_simu_Dstar/dstar_1.6/contour/bla0.17.csv" u (-($2)*1e6):(($3)*1e6) w l lw 3 lc rgbcolor "0x0000FF" dt 1 t "" 
