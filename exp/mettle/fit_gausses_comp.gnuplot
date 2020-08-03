#!/bin/gnuplot
# 
reset
set term x11
set output

set grid
set ylabel "converted light energy [J/cm^2]"
set y2label "photodiode voltage [mV]"
set y2tics
set title "Energy emission by METTLE flash at highest power\n Comparison to LED flash by using a 1{/Symbol m}s window"

# 
# p "METTLE_raw.dat" u 1:(($2)*1.69771E-04) w lp t "METTLE"
# 
# pause -1 "hit enter"
# 
# set term postscript eps color enhanced solid
# set output "METTLE_conv.eps"
# replot
# !epstopdf METTLE_conv.eps
# !rm *.eps

conv=5.312974889616E-08 #J/mV/cm^2

set yrange [0:3000*conv]
set y2range [0:3000]


sigma_x1 = 4.
sigma_x2 = 4.
sigma_x3 = 2.
amp_x1 = 0.7
amp_x2 = -0.4
amp_x3 = 0.2
offset = 10.

f(x) = exp(-(x-offset)**2/sigma_x1**2)*amp_x1 + exp(-(x-offset)**2/sigma_x2**2)*amp_x2 + exp(-(x-offset)**2/sigma_x3**2)*amp_x3

fit f(x) "METTLE_raw.dat" u 1:(($2)*conv) via sigma_x1, sigma_x2, sigma_x3, amp_x1, amp_x2, amp_x3
p "METTLE_raw.dat" u 1:2        axis x1y2 w l lw 0 t "",\
  "METTLE_raw.dat" u 1:(($2)*conv) w lp     t "converted",\
  f(x)                                             t "fit"

pause -1 "hit enter"
  
set term postscript eps color enhanced solid
set output "intensity_comp.eps"
replot
!epstopdf "intensity_comp.eps"
!rm *.eps