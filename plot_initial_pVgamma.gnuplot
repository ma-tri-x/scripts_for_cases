#!/bin/gnuplot

reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "initial_pVgamma.eps"

set grid

R=20e-6
gamma=1.4
approx_pressure = 1.1e9 #1209948400.0
const_expected = approx_pressure*(4.*pi/3.*R**3)**gamma

print(sprintf("expected volumes for wedge: %e",4.*pi/3.*R**3/180.*0.5))
print(sprintf("expected constants: %e",const_expected))

set xlabel "grid resolution [{/Symbol m}m]"
set ylabel "p_0{V_0}^{/Symbol g}/K"

set title sprintf("adiabatic constant normalized with\n\n K=%.1f GPa (4{/Symbol p}/3 (%.0f{/Symbol m}m)^3)^{%.1f} [N*m^{1.4}]",approx_pressure/1e9, R*1e6,gamma)

#V0(vol,theta)
V0(x,y)=x*180./y
#p0gamma(vol,theta,p)
pVgamma(x,y,z)=z*V0(x,y)**1.4/const_expected


set xrange [0.5:4.5]

p "Rmax.dat" u (($1)*1e6):(pVgamma(($5),($4),($6))) w p ps 2 lw 2 notitle
