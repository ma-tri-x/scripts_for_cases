#!/bin/gnuplot

reset
set term x11
set output

set grid
set xlabel "time [ms]"
set ylabel "photodiode voltage [mV]"
set y2label "photodiode voltage [mV] of pulse 2"
set title "pulses of METTLE 600 DR flash, measured at different spots\n read via imagej"
set y2tics

p "pulse_raw.dat"  u (($1)):(($2)) w lp t "pulse 1",\
  "pulse2_raw.dat" u (($1)):(($2)) axis x1y2 w lp t "pulse 2"

pause -1 "hit enter"

set term postscript eps color enhanced solid
set output "pulse_signal.eps"
replot
!epstopdf pulse_signal.eps
!rm *.eps

reset
set term x11
set output

set grid

set xlabel "wavelenght [nm]"
set ylabel "Responsivity R_{/Symbol l} [A/W]"
set y2label "normalized daylight spec. and multiplied spec. [a.u.]"
set y2tics

h=6.62607004e-34 #Js
c=299792458 #m/s
k=1.38064852e-23 #J/K

c1=2.*pi*h*c*c/(1e-9)**5
c2=h*c/k/1e-9

norm= 4.470555350177E+16

T=5777.

f(x)=c1/x**5/(exp(c2/x/T)-1.)/norm

p "spectra.dat" u 1:3 w lp           t "R({/Symbol l})",\
  f(x) axis x1y2                     t sprintf("normalized black body at T=%.0f K",T),\
  ""            u 1:4 w lp axis x1y2 t "multiplied spectra"

pause -1 "hit enter"
  #""            u 1:2 w lp axis x1y2 t "normalized daylight black body"

set term postscript eps color enhanced solid
set output "spectra.eps"
replot
!epstopdf spectra.eps
!rm *.eps
