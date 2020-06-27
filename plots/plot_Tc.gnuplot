#!/bin/gnuplot

reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Tc.eps"

set grid
set key above

set ylabel "2 T_{c} [{/Symbol m}s]"
set xlabel "res. [{/Symbol m}m]"

set xrange [0.1:3.2]
set yrange [99.4:101.1]

p \
"Tc_Econst.dat"   u (($1)*1e6):(($2)*1e6) w lp lw 3 t "case a0)",\
"Tc_RnChange.dat"   u (($1)*1e6):(($2)*1e6) w lp lw 4 dt 2 t "case a)",\
"Tc_maxCo01.dat"   u (($1)*1e6):(($2)*1e6) w lp t "case b)",\
"Tc_tRn60mus.dat"   u (($1)*1e6):(($2)*1e6) w lp t "case c)",\
"Tc_refine.dat"   u (($1)*1e6):(($2)*1e6) w lp lc 7 t "case d)",\
"Tc_refine_low_res.dat"   u (($1)*1e6):(($2)*1e6) w lp lc 8 t "case e)",\
"Tc_spherical.dat"   u (($1)*1e6):(($2)*1e6) w lp t "E=const. + etc. + spherical",\
"Tc_unbound.dat"   u (($1)*1e6):(($2)*1e6) w lp t "E=const. + axisymm + unbound",\
"Tc_unbound_int3cells.dat"   u (($1)*1e6):(($2)*1e6) w lp t "axisymm + unbound + 3cells int.f." 
"Tc_spherical.dat"   u (($1)*1e6):(($2)*1e6) w lp t "E=const. + etc. + spherical",\
"Tc_unbound.dat"   u (($1)*1e6):(($2)*1e6) w lp t "E=const. + axisymm + unbound",\
"Tc_unbound_int3cells.dat"   u (($1)*1e6):(($2)*1e6) w lp t "axisymm + unbound + 3cells int.f." 
