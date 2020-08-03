#!/bin/gnuplot

reset
set term x11
set output

set grid
set xlabel "wavelength [nm]"
set ylabel "arbitrary units [normalized]"

set xrange [300:1050]

h=6.62607004e-34 #Js
c=299792458 #m/s
k=1.38064852e-23 #J/K

c1=2.*pi*h*c*c/(1e-9)**5
c2=h*c/k/1e-9

norm= 4.470555350177E+16

T=5777.

f(x)=c1/x**5/(exp(c2/x/T)-1.)/norm

p f(x) t sprintf("black body at T=%.0f",T)

pause -1 "hit enter"

set term postscript eps color enhanced solid
set output "black_body.eps"
replot
!epstopdf black_body.eps
!rm *.eps

# 
# reset
# set term x11
# set output
# 
# set grid
# 
# set xlabel "wavelenght [nm]"
# set ylabel "Responsivity R_{/Symbol l} [A/W]"
# 
# p "spectrum_transformed.dat" w lp t "read via imagej"
# 
# pause -1 "hit enter"
# 
# set term postscript eps color enhanced solid
# set output "spectrum.eps"
# replot
# !epstopdf spectrum.eps
# !rm *.eps
