reset

set term x11
set output

set grid
set y2tics
set key top center

gamma=1.4
pinf=101315.
Rn=0.000184103703538
Vn=4./3.*pi*(Rn)**3
theta=system("cat THETA")

set xlabel "time [mus]"
set ylabel "E/E0"
set y2label "radius [m]"

p0=1142808398.28
V0=2.5700959413427e-19

#x=avg_pg  y=V
#V(x)=x/theta*180.
V(x)=pi*x/(tan(theta*pi/180.))**2
V0=V(V0)
pVgamma(x,y)= x*V(y)**gamma
energy(x,y)=(x*V(y)-pinf*Vn)/(gamma-1.) + pinf*(V(y)-V0)
energy2(x)=(pinf*Vn)/(gamma-1.) *((Vn/V(x))**(gamma-1.) - 1.) + pinf*(V(x)-V0)
energy3(x)=V(x)<Vn?(pinf*Vn)/(gamma-1.) *((Vn/V(x))**(gamma-1.) - 1.) + pinf*(V(x)-V0):pinf*(V(x)-V0)
R(x)=(3.*x/4./(tan(theta*pi/180.))**2)**(1./3.)

pvgamma0=p0*V0**gamma
Etot=(p0*V0-pinf*Vn)/(gamma-1)
Etot2=system("cat Etot")

#1      2        3         4    5       6    7         8
#t*1e6,al[i][1],radii[i],AC[i],ACG[i],KI[i],potEn[i],totEn
p \
  "postProcessing/volumeIntegrate_volumeIntegral/0/Energies" \
       u 1:(($3)*1e6) w l lw 3 axes x1y2 t "R(t)" ,\
  ""   u 1:(($4)/ Etot) w l lw 3 t "Ac En. water",\
  ""   u 1:(($6)/ Etot) w l lw 3 t "kin. En.",\
  ""   u 1:(($7)/ Etot) w l lw 3 t "pot. En.",\
  ""   u 1:(($5)/ Etot) w l lw 3 t "Ac En. bubble",\
  "incompressible_Rt.dat" u (($1)*1e6):($3) w l lw 3 lc 7 dt 3 t "incompressible energy"
  
  #""   u 1:(($8)/ Etot) w l lw 2 t "total Energy",\
