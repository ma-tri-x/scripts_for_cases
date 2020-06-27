#!/bin/gnuplot

reset
#set term wxt
#set output

set term postscript eps color enhanced solid font "DejaVuSerif, 20"
set output "sigma_comparison.eps"

set grid
set key above
set xlabel "x [{/Symbol m}m]"
set ylabel "y [{/Symbol m}m]"

set xtics autofreq 200
set ytics autofreq 200

set xrange [-500:500]
set yrange [-400:500]

set size ratio -1

set datafile separator ","

plot "temp/sigma_piston.dat" u 1:2 w l lc 7 lw 3 t "no sigma",\
"temp/sigma_piston.dat" u 1:2 w l lc 2 lw 3 t "with sigma",\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.253.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.253.csv" u (-($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.290.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.290.csv" u (-($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.278.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.278.csv" u (-($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.331.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.331.csv" u (-($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.292.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.292.csv" u (-($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.342.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.342.csv" u (-($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.311.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum/contour/bla0.311.csv" u (-($2)*1e6):(($3)*1e6) w l lc 7 lw 6 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.362.csv" u ( ($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"../kk010_piston_axi_static_Rn240.0mum_dinit250mum_sigma/contour/bla0.362.csv" u (-($2)*1e6):(($3)*1e6) w l lc 2 lw 3 notitle,\
"temp/sigma_piston.dat" u 1:2 w l lw 2 lc rgbcolor "black" notitle
