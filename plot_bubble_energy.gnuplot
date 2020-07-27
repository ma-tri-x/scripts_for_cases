reset

set term x11
set output

set grid
set y2tics
set key top center

gamma=1.4
pinf=101315.
Vn=4./3.*pi*(0.000184103703538)**3
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


AcEn(x)=(pi/(tan(theta*pi/180.))**2)*x/(998.*1450**2)
KinEn(x)=(pi/(tan(theta*pi/180.))**2)*x


R(x)=(3.*x/4./(tan(theta*pi/180.))**2)**(1./3.)

pvgamma0=p0*V0**gamma
Etot=(p0*V0-pinf*Vn)/(gamma-1)

print pvgamma0
print Etot
print Vn
print V(2.0071213964765e-16)

p \
  "postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" u (($1)*1e6):( R($2)) w l lw 3 axes x1y2 t "R(t)" ,\
  "postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" u (($1)*1e6):( energy2(($2))/ Etot) w l lw 3 t "energy factor without avg pg",\
  "postProcessing/volumeIntegrate_volumeIntegral/0/AcousticEnergy" u (($1)*1e6):( AcEn(($2))/ Etot) w l lw 3 t "Acoustic Energy",\
  "postProcessing/volumeIntegrate_volumeIntegral/0/KineticEnergy" u (($1)*1e6):( KinEn(($2))/ Etot) w l lw 3 t "Kinetic Energy",\
  "incompressible_Rt.dat" u (($1)*1e6):($3) w l lw 3 lc 7 dt 3 t "incompressible energy"
  
