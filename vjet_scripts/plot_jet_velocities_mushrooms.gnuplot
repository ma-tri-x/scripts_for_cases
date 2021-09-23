#!/bin/gnuplot
reset

set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "jet_velocities_mushrooms.eps"
set lmargin at screen 0.1
set rmargin at screen 0.85
set tmargin at screen 0.9
set bmargin at screen 0.15
#set palette rgb 33,13,10 # rainbow
set palette file "-"
0 0 0
1 .8 0
1 0 0
e
set grid
set view map
set pm3d
set palette color

set xlabel "r_p^*"
set ylabel "D^*"

Rmaxubd(x)=(3.1662*x*1e6-83.1)*1e-6

dstar(x,y)=x/Rmaxubd(y)
rpstar(x)=272.8e-6/Rmaxubd(x)

set key above

set title "jet velocities"
#Rn    dinit    vjet   vjet_min
splot "jet_velocities_summary_save.dat" u (rpstar($1)):(dstar($2,$1)):3 w p pt 5 ps 2 palette t ""

!epstopdf jet_velocities_mushrooms.eps
!rm jet_velocities_mushrooms.eps


set output "jet_velocities_mushrooms_maxvel.eps"
set title "max. velocities on y-axis"
#Rn    dinit    vjet   vjet_min
splot "jet_velocities_summary_save.dat" u (rpstar($1)):(dstar($2,$1)):4 w p pt 5 ps 2 palette t ""

!epstopdf jet_velocities_mushrooms_maxvel.eps
!rm jet_velocities_mushrooms_maxvel.eps
