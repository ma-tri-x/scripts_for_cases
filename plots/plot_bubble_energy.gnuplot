reset

#set term x11
#set output
set term postscript eps color enhanced solid font "DejaVuSerif, 16"
set output "Energy_bubble_energy_for_report.eps"

set grid
set y2tics
set key above

gamma=1.4
pinf=101315.
Rn=0.000184103703538
R0=20.063e-6
theta=system("cat THETA")

set xlabel "time [{/Symbol m}s]"
set ylabel "E/E0"
set y2label "radius [{/Symbol m}m]"

Vn=4./3.*pi*(Rn)**3
V0=4.*pi/3.*R0**3
p0=pinf*(Rn/R0)**(3.*gamma)

# V(x)=pi*x/(tan(theta*pi/180.))**2
# V0=V(V0)
# pVgamma(x,y)= x*V(y)**gamma
# energy(x,y)=(x*V(y)-pinf*Vn)/(gamma-1.) + pinf*(V(y)-V0)
# energy2(x)=(pinf*Vn)/(gamma-1.) *((Vn/V(x))**(gamma-1.) - 1.) + pinf*(V(x)-V0)
# energy3(x)=V(x)<Vn?(pinf*Vn)/(gamma-1.) *((Vn/V(x))**(gamma-1.) - 1.) + pinf*(V(x)-V0):pinf*(V(x)-V0)
# R(x)=(3.*x/4./(tan(theta*pi/180.))**2)**(1./3.)

Etot=(p0*V0-pinf*Vn)/(gamma-1.) + pinf*(V0-Vn)
print Etot, 9.19747493822e-10

#set xrange [-2:*]
set xrange [-0.1:0.5]
set yrange [*:1.05]

#1      2        3         4    5       6    7         8
#t*1e6,al[i][1],radii[i],AC[i],ACG[i],KI[i],potEn[i],totEn
p \
  "postProcessing/volumeIntegrate_volumeIntegral/0/Energies" \
       u 1:(($3)*1e6) w l lw 3 axes x1y2 t "R(t) full CFD" ,\
  ""   u 1:(($6)/ Etot) w l lw 3 t "kin. en.",\
  ""   u 1:(($7)/ Etot) w l lw 3 t "pot. en.",\
  ""   u 1:(($4)/ Etot) w l lw 5 lc 7 t "ac. en. water",\
  ""   u 1:(($5)/ Etot) w l lw 3 t "ac. en. bubble",\
  ""   u 1:(($8)/ Etot) w l lw 5 lc 9 dt 3 t "total energy" ,\
  "incompressible_Rt.dat" u (($1)*1e6):($3) w l lw 3 lc 8 dt 3 t "Rayleigh-Plesset pot. en."
  
  #""   u 1:(($8)/ Etot) w l lw 2 t "total Energy",\
  
!epstopdf Energy_bubble_energy_for_report.eps
!rm Energy_bubble_energy_for_report.eps
!pdfcrop Energy_bubble_energy_for_report.pdf Energy_bubble_energy_for_report.pdf
