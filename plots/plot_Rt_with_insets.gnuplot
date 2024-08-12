reset

set term qt
set output

set grid 
set key above

set xlabel "time [{/Symbol m}s]"
set ylabel "Radius [{/Symbol m}m]"
set title "R(t) with shockwave of 15.9MPa"

set multiplot

set size 1,1
p "gilmore2_15.9MPa.dat" u (($1)*1e6):(($2)*1e6) w l not

unset title
set size 0.5,0.42
set origin 0.45,0.5
set ytics autofreq 0.1
unset key
unset ylabel
unset xlabel
set object 1 rectangle from graph 0,0 to graph 1,1 fc rgb "#04AA40" fillstyle solid 0.0 noborder
set grid front
set xrange [0:0.1]
p "gilmore2_15.9MPa.dat" u (($1)*1e6):(($2)*1e6) w l not

pac=15.9e6
decay_rate=9.1e5
omega=2*pi*83.3e3
shw(x)=2*pac*1e-6*exp(-decay_rate*(x*1e-6))*cos(pi/3 + omega*(x*1e-6))

set origin 0.45,0.13
set size 0.5,0.38
set ylabel "p [MPa]"
set xrange [0:8]
set ytics autofreq 4
p shw(x) w l lc 2 t "shockwave", 0 lc 8 not

unset multiplot

pause -1
  
reset
set term postscript eps color enhanced solid font "DejaVuSerif, 16"
set output "Rt_15.9MPa_with_shw.eps"
#replot
################## unfortunately replot cannot replot the whole set, but only the last inset

set grid 
set key above

set xlabel "time [{/Symbol m}s]"
set ylabel "Radius [{/Symbol m}m]"
set title "R(t) with shockwave of 15.9MPa"

set multiplot

set size 1,1
p "gilmore2_15.9MPa.dat" u (($1)*1e6):(($2)*1e6) w l not

unset title
set size 0.5,0.42
set origin 0.45,0.5
set ytics autofreq 0.1
unset key
unset ylabel
unset xlabel
set object 1 rectangle from graph 0,0 to graph 1,1 fc rgb "#04AA40" fillstyle solid 0.0 noborder
set grid front
set xrange [0:0.1]
p "gilmore2_15.9MPa.dat" u (($1)*1e6):(($2)*1e6) w l not

pac=15.9e6
decay_rate=9.1e5
omega=2*pi*83.3e3
shw(x)=2*pac*1e-6*exp(-decay_rate*(x*1e-6))*cos(pi/3 + omega*(x*1e-6))

set origin 0.45,0.13
set size 0.5,0.38
set ylabel "p [MPa]"
set xrange [0:8]
set ytics autofreq 4
p shw(x) w l lc 2 t "shockwave", 0 lc 8 not

unset multiplot


!epstopdf Rt_15.9MPa_with_shw.eps
!rm Rt_15.9MPa_with_shw.eps
!pdfcrop Rt_15.9MPa_with_shw.pdf Rt_15.9MPa_with_shw.pdf
