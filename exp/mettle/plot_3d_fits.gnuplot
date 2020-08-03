#!/bin/gnuplot

reset
set term x11
set output

set pm3d map
set samples 100; set isosamples 100
set multiplot
set rmargin at screen 0.83
set lmargin at screen 0.08

set size square

sigma_x1        = 4.30323     #     +/- 26.12        (607.1%)
sigma_x2        = 4.02335     #     +/- 47.75        (1187%)
sigma_x3        = 3.67499     #     +/- 21.64        (588.7%)
amp_x1          = 47.4406     #     +/- 1.25e+04     (2.635e+04%)
amp_x2          = -76.5306    #     +/- 6697         (8751%)
amp_x3          = 29.5822     #     +/- 5847         (1.976e+04%)

r(x,y) = sqrt(x**2+y**2)
f(x,y) = exp(-(r(x,y)/sigma_x1)**2)*amp_x1    +      exp(-(r(x,y)/sigma_x2)**2)*amp_x2    +      exp(-(r(x,y)/sigma_x3)**2)*amp_x3

set xrange[-12:12]
set yrange[-12:12]
set cbrange [0:0.6]

set xlabel "x-axis [cm]"
set ylabel "y-axis [cm]"
set title "intensity [J/cm^2]"
splot f(x,y)
unset multiplot
pause -1

set term postscript eps color enhanced solid
set output "3d_fits.eps"
replot
!epstopdf 3d_fits.eps
!rm *.eps