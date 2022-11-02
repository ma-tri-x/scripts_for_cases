reset

set term x11
set output

set grid 
set key above

set pm3d
set view map
set palette color

set ylabel "time [{/Symbol m}s]"
set xlabel "mode number"
set cblabel "amplitude [{/Symbol m}m]"

set logscale cb
# set cbrange [0:200]


m0(x)=0
m1(x)=1
m2(x)=2
m3(x)=3
m4(x)=4
m5(x)=5
m6(x)=6
m7(x)=7
m8(x)=8

p "MODES_Rn164.3_20kHz_0.8.dat" u (m0($1)):(($1)*1e6):abs(2 ) w l lw 12 palette not,\
  ""                            u (m1($1)):(($1)*1e6):abs(3 ) w l lw 12 palette not,\
  ""                            u (m2($1)):(($1)*1e6):abs(4 ) w l lw 12 palette not,\
  ""                            u (m3($1)):(($1)*1e6):abs(5 ) w l lw 12 palette not,\
  ""                            u (m4($1)):(($1)*1e6):abs(6 ) w l lw 12 palette not,\
  ""                            u (m5($1)):(($1)*1e6):abs(7 ) w l lw 12 palette not,\
  ""                            u (m6($1)):(($1)*1e6):abs(8 ) w l lw 12 palette not,\
  ""                            u (m7($1)):(($1)*1e6):abs(9 ) w l lw 12 palette not,\
  ""                            u (m8($1)):(($1)*1e6):abs(10) w l lw 12 palette not

# pause -1
#   
# set term postscript eps color enhanced solid font "DejaVuSerif, 16"
# set output "bla.eps"
# replot
# 
# !epstopdf bla.eps
# !rm bla.eps
