#!/bin/gnuplot

reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Tc.eps"

set grid
set key above

set ylabel "2 T_{c} [{/Symbol m}s]"
set xlabel "cell size in initial bubble area [{/Symbol m}m]"

set xrange [0.08:*]
set yrange [*:*]
set logscale x

p \
"Tc_spherical_XF100.dat"   u (($1)*1e6):(($2)*1e6) w lp lc 7 t "converged spherical calc.",\
"Tc_unbound.dat"   u (($1)*1e6):(($2)*1e6) w lp lc 2 t "axisymm. polar mesh",\
"Tc_unbound_refine_low_res_XF100.dat"   u (($1)*1e6):(($2)*1e6) w lp t "axisymm. + concentric refinement + BC moved to 100Rmax" 
