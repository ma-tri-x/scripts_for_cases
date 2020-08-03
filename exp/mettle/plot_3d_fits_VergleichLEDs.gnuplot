#!/bin/gnuplot

reset
set term x11
set output

set pm3d map
set samples 100; set isosamples 100
set multiplot
set rmargin at screen 0.83
set lmargin at screen 0.08

set title "Comparison to LED flash by using 1{/Symbol m}s window"

set size square

sigma_x1        = 4.09533      #    +/- 826.4        (2.018e+04%)
sigma_x2        = 4.07853      #    +/- 1448         (3.551e+04%)
sigma_x3        = 3.83306      #    +/- 73.49        (1917%)
amp_x1          = 0.447996     #    +/- 6.267e+04    (1.399e+07%)
amp_x2          = -0.475446    #    +/- 6.264e+04    (1.318e+07%)
amp_x3          = 0.0275761    #    +/- 31.76        (1.152e+05%)

r(x,y) = sqrt(x**2+y**2)
f(x,y) = exp(-(r(x,y)/sigma_x1)**2)*amp_x1    +      exp(-(r(x,y)/sigma_x2)**2)*amp_x2    +      exp(-(r(x,y)/sigma_x3)**2)*amp_x3

set xrange[-12:12]
set yrange[-12:12]

set xlabel "x-axis [cm]"
set ylabel "y-axis [cm]"
set title "intensity [J/cm^2]"
splot f(x,y)
unset multiplot
pause -1

set term postscript eps color enhanced solid
set output "3d_fitsComparison.eps"
replot
!epstopdf 3d_fitsComparison.eps
!rm *.eps