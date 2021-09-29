#!/bin/gnuplot
reset

set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "jet_velocities_mushrooms.eps"
# set term x11
# set output

set lmargin at screen 0.12
set rmargin at screen 0.85
set tmargin at screen 0.9
set bmargin at screen 0.15
# set palette model HSV
# set palette rgb 3,2,2
# set palette rgb 33,13,10 # rainbow
# set palette file "-"
# 0.65 0.65 0.65
# 0 0 .9
# 1 .8 0
# 1 0 0
# e
set palette maxcolors 100
set palette defined ( 0 '#0000ff',\
                      600 '#bbbbbb',\
                      1000 '#00aa00',\
                      1400 '#aa0000',\
                      1600 '#ff0000')
#                       600 '#009090',\
set view map
set grid
set view map
set pm3d
set palette color

set cbrange [0:1400]
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*"

Rmaxubd(x)=(3.1662*x*1e6-83.1)*1e-6

dstar(x,y)=x/Rmaxubd(y)
#rpstar(x)=272.8e-6/Rmaxubd(x)
rpstar(x)=200e-6/Rmaxubd(x)

is_fastjet(x,y)= x == 1 ? y : 1/0.
is_stndjet(x,y)= x == 0 ? y : 1/0.

set key above

set title "jet velocities"
#Rn    dinit    vjet   vjet_min
splot "jet_velocities_summary_save.dat" u (rpstar($1)):(dstar($2,$1)):(is_fastjet(($9),($3))) w p pt 5 ps 2 palette t "",\
      ""                                u (rpstar($1)):(dstar($2,$1)):(is_stndjet(($9),($3))) w p pt 4 ps 2 t "standard jet"

!epstopdf jet_velocities_mushrooms.eps
!rm jet_velocities_mushrooms.eps


set output "jet_velocities_mushrooms_maxvel.eps"
set title "max. velocities on y-axis"
#Rn    dinit    vjet   vjet_min
splot "jet_velocities_summary_save.dat" u (rpstar($1)):(dstar($2,$1)):(is_fastjet(($9),($4))) w p pt 5 ps 2 palette t "",\
      ""                                u (rpstar($1)):(dstar($2,$1)):(is_stndjet(($9),($4))) w p pt 4 ps 2 t "standard jet"

!epstopdf jet_velocities_mushrooms_maxvel.eps
!rm jet_velocities_mushrooms_maxvel.eps

set output "jet_velocities_mushrooms_zoom.eps"
set key above
set yrange [:2.5]
set title "jet velocities in the mushroom domain"
#Rn    dinit    vjet   vjet_min
splot "jet_velocities_summary_save.dat" u (rpstar($1)):(dstar($2,$1)):(is_fastjet(($9),($3))) w p pt 5 ps 2 palette t "",\
      ""                                u (rpstar($1)):(dstar($2,$1)):(is_stndjet(($9),($3))) w p pt 4 ps 2 t "standard jet"

!epstopdf jet_velocities_mushrooms_zoom.eps
!rm jet_velocities_mushrooms_zoom.eps

set output "jet_velocities_mushrooms_only.eps"
set key above
set yrange [:.6]
set cbrange [*:*]
set title "jet velocities in the mushroom domain only"
#Rn    dinit    vjet   vjet_min
splot "jet_velocities_summary_save.dat" u (rpstar($1)):(dstar($2,$1)):(is_fastjet(($9),($3))) w p pt 5 ps 2 palette t ""

!epstopdf jet_velocities_mushrooms_only.eps
!rm jet_velocities_mushrooms_only.eps
