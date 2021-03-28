#!/bin/gnuplot

reset
set term png
set output "MKFabiansDiagramm.png"
set multiplot
set xrange [0:669] 
set yrange [0:347]
#As the background picture's size is 670x348,
#we choose xrange and yrange of these values
unset tics
unset border
set lmargin at screen 0
set rmargin at screen 1
set bmargin at screen 0
set tmargin at screen 1
#Plot the background image
plot "fabians_diagramm/fabians_diagramm.png" binary filetype=png w rgbimage
#The x and y range of the population data file
set xrange [0:3.5]
set yrange [0:1]
unset ytics
unset xtics
unset border
set lmargin at screen 0.094
set rmargin at screen 0.866
set bmargin at screen 0.38
set tmargin at screen 0.73
##width height
# 670	348 full image
# 65     58 origin -> 0.097,0.167
# 580       3.5 of x-axis -> 0.866
#       130 wall-vortex -> 0.374
#       252 free vortex -> 0.724
# set grid
# set tics out nomirror scale 2
# set mxtics 5
set key above
# set xlabel "Year"
# set ylabel "Population(in millions)"
dstar_to_gamma(x)=1.01247*x+0.00918621
plot "vortices_simulated.dat" u (dstar_to_gamma(($1))):2 w p ps 3 pt 3 lw 1.8 lc rgbcolor "#006600" title "calculated"
unset multiplot
