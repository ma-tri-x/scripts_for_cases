#!/bin/gnuplot
reset

set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "jet_length_mushrooms_normrp.eps"
# set term x11
# set output
set lmargin at screen 0.12
set rmargin at screen 0.85
set tmargin at screen 0.9
set bmargin at screen 0.15

inputfile = "jet_velocities_summary_save2021-10-12_selected.dat"

set palette maxcolors 40
set palette defined ( 0 '#0000ff',\
                      .6 '#bbbbbb',\
                      .8 '#aa0000',\
                      1.1 '#ff0000')
                      
set view map
set palette color
set pm3d corners2color mean
set contour surface
set surface
set dgrid3d 180,140,3
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*" norotate offset 2
set key above

Rmaxubd(x)=(3.1662*x*1e6-83.1)*1e-6

# x=Rn, y=dinit
dstar(x,y)=y/Rmaxubd(x)

# x=Rn, y=rp
rpstar(x,y)=y/Rmaxubd(x)

# x=Rn, y=distance or length, z=rp, t=is_fast_jet
distance_normrp(x,y,z,t)= t == 1 && y > 0 ? y/z : 1/0
#distance_normRn(x,y,z,t)= t == 1 && y > 0 ? y/Rmaxubd(x) : 1/0
# 

#set cbrange [0.5:0.95]

#1     2        3     4             5           6                            7             8   9    10
#Rn    dinit    rp    vjet_byDef    v_minmin    dist_from_solid_formation    interval_t1   t2  dt   is_fast_jet
set table "interpolation_normrp.txt"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normrp($1,$6,$3,$10)) 
unset table

set contour
unset surface
set cntrparam levels auto 15 # Modify this to your liking
set view map
unset clabel

set table "contours_normrp.dat"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normrp($1,$6,$3,$10)) notitle
unset table
unset contour

unset dgrid3d
unset contour
unset surface
unset pm3d
set palette color
set xrange [0.28:1]
set yrange [0:1]
set cbrange [0:3]

set multiplot
set xtics textcolor rgbcolor '#ffffff'
set ytics textcolor rgbcolor '#ffffff'
set ylabel textcolor rgbcolor '#ffffff'
set xlabel textcolor rgbcolor '#ffffff'
set cblabel textcolor rgbcolor '#ffffff'
set title ""
splot  "interpolation_normrp.txt" u 1:2:3 w image not  

set xtics textcolor rgbcolor '#000000'
set ytics textcolor rgbcolor '#000000'
set ylabel textcolor rgbcolor '#000000' 
set xlabel textcolor rgbcolor '#000000'
set cblabel textcolor rgbcolor '#000000'

#set style rect fc lt -1 fs solid 0.15 noborder
#set object 1 rect from 0,0 to 0.28,1 fc rgbcolor '#ffffff' front

set title "jet length / r_p"
 
plot  "contours_normrp.dat" u 1:2 w l lc 0 not,\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normrp($1,$6,$3,$10)) w p pt 5 ps 2 palette t "",\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normrp($1,$6,$3,$10)) w p pt 4 ps 2 lc 8 t ""
unset multiplot

!epstopdf jet_length_mushrooms_normrp.eps
!rm jet_length_mushrooms_normrp.eps

!rm interpolation_normrp.txt contours_normrp.dat










##########################################

set output "jet_length_mushrooms_normRn.eps"

set palette maxcolors 40
set palette defined ( 0 '#0000ff',\
                      .6 '#bbbbbb',\
                      .8 '#aa0000',\
                      1.1 '#ff0000')
                      
set view map
set palette color
set pm3d corners2color mean
set contour surface
set surface
set dgrid3d 180,140,3
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*" norotate offset 2
set key above


distance_normRn(x,y,z,t)= t == 1 && y > 0 ? y/Rmaxubd(x) : 1/0
# 

#set cbrange [0.5:0.95]

#1     2        3     4             5           6                            7             8   9    10
#Rn    dinit    rp    vjet_byDef    v_minmin    dist_from_solid_formation    interval_t1   t2  dt   is_fast_jet
set table "interpolation_normRn.txt"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normRn($1,$6,$3,$10)) 
unset table

set contour
unset surface
set cntrparam levels auto 15 # Modify this to your liking
set view map
unset clabel

set table "contours_normRn.dat"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normRn($1,$6,$3,$10)) notitle
unset table
unset contour

unset dgrid3d
unset contour
unset surface
unset pm3d
set palette color
set xrange [0.28:1]
set yrange [0:1]
set cbrange [0.4:1.2]

set multiplot
set xtics textcolor rgbcolor '#ffffff'
set ytics textcolor rgbcolor '#ffffff'
set ylabel textcolor rgbcolor '#ffffff'
set xlabel textcolor rgbcolor '#ffffff'
set cblabel textcolor rgbcolor '#ffffff'
set title ""
splot  "interpolation_normRn.txt" u 1:2:3 w image not  

set xtics textcolor rgbcolor '#000000'
set ytics textcolor rgbcolor '#000000'
set ylabel textcolor rgbcolor '#000000' 
set xlabel textcolor rgbcolor '#000000'
set cblabel textcolor rgbcolor '#000000'

#set style rect fc lt -1 fs solid 0.15 noborder
#set object 1 rect from 0,0 to 0.28,1 fc rgbcolor '#ffffff' front

set title "jet length / R_{max,unbound}"
 
plot  "contours_normRn.dat" u 1:2 w l lc 0 not,\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normRn($1,$6,$3,$10)) w p pt 5 ps 2 palette t "",\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(distance_normRn($1,$6,$3,$10)) w p pt 4 ps 2 lc 8 t ""
unset multiplot

!epstopdf jet_length_mushrooms_normRn.eps
!rm jet_length_mushrooms_normRn.eps

!rm interpolation_normRn.txt contours_normRn.dat










##########################################

set output "jet_velocities_mushrooms.eps"

set palette maxcolors 40
set palette defined ( 0 '#0000ff',\
                      .6 '#bbbbbb',\
                      .8 '#aa0000',\
                      1.1 '#ff0000')
                      
set view map
set palette color
set pm3d corners2color mean
set contour surface
set surface
set dgrid3d 180,140,3
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*" norotate offset 2
set key above

# x=vjet, y=distance, z=is_fast_jet
velocity(x,y,z)= z == 1 && y > 0 ? x : 1/0
# 

#set cbrange [0.5:0.95]

#1     2        3     4             5           6                            7             8   9    10
#Rn    dinit    rp    vjet_byDef    v_minmin    dist_from_solid_formation    interval_t1   t2  dt   is_fast_jet
set table "interpolation_velocity.txt"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(velocity($4,$6,$10)) 
unset table

set contour
unset surface
set cntrparam levels auto 15 # Modify this to your liking
set view map
unset clabel

set table "contours_velocity.dat"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(velocity($4,$6,$10)) notitle
unset table
unset contour

unset dgrid3d
unset contour
unset surface
unset pm3d
set palette color
set xrange [0.28:1]
set yrange [0:1]
set cbrange [200:2200]

set multiplot
set xtics textcolor rgbcolor '#ffffff'
set ytics textcolor rgbcolor '#ffffff'
set ylabel textcolor rgbcolor '#ffffff'
set xlabel textcolor rgbcolor '#ffffff'
set cblabel textcolor rgbcolor '#ffffff'
set title ""
splot  "interpolation_velocity.txt" u 1:2:3 w image not  

set xtics textcolor rgbcolor '#000000'
set ytics textcolor rgbcolor '#000000'
set ylabel textcolor rgbcolor '#000000' 
set xlabel textcolor rgbcolor '#000000'
set cblabel textcolor rgbcolor '#000000'

#set style rect fc lt -1 fs solid 0.15 noborder
#set object 1 rect from 0,0 to 0.28,1 fc rgbcolor '#ffffff' front

set title "v_{jet} [m/s] (error estimated to 500 m/s)"
 
plot  "contours_velocity.dat" u 1:2 w l lc 0 not,\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(velocity($4,$6,$10)) w p pt 5 ps 2 palette t "",\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(velocity($4,$6,$10)) w p pt 4 ps 2 lc 8 t ""
unset multiplot

!epstopdf jet_velocities_mushrooms.eps
!rm jet_velocities_mushrooms.eps

!rm interpolation_velocity.txt contours_velocity.dat












##########################################

set output "jet_intervals.eps"

set palette maxcolors 40
set palette defined ( 0 '#0000ff',\
                      .6 '#bbbbbb',\
                      .8 '#aa0000',\
                      1.1 '#ff0000')
                      
set view map
set palette color
set pm3d corners2color mean
set contour surface
set surface
set dgrid3d 180,140,3
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*" norotate offset 2
set key above

TRc(x) = 0.91468*Rmaxubd(x)*sqrt(998./101315.) # Rayleigh collapse time

# x=dt, y=distance, z=Rn, t=is_fast_jet
interval(x,y,z,t)= t == 1 && y > 0 ? 100*x/TRc(z) : 1/0
# 

#set cbrange [0.5:0.95]

#1     2        3     4             5           6                            7             8   9    10
#Rn    dinit    rp    vjet_byDef    v_minmin    dist_from_solid_formation    interval_t1   t2  dt   is_fast_jet
set table "interpolation_dt.txt"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(interval($9,$6,$1,$10)) 
unset table

set contour
unset surface
set cntrparam levels auto 15 # Modify this to your liking
set view map
unset clabel

set table "contours_dt.dat"
splot inputfile u (rpstar($1,$3)):(dstar($1,$2)):(interval($9,$6,$1,$10)) notitle
unset table
unset contour

unset dgrid3d
unset contour
unset surface
unset pm3d
set palette color
set xrange [0.28:1]
set yrange [0:1]
set cbrange [*:*]

set multiplot
set xtics textcolor rgbcolor '#ffffff'
set ytics textcolor rgbcolor '#ffffff'
set ylabel textcolor rgbcolor '#ffffff'
set xlabel textcolor rgbcolor '#ffffff'
set cblabel textcolor rgbcolor '#ffffff'
set title ""
splot  "interpolation_dt.txt" u 1:2:3 w image not  

set xtics textcolor rgbcolor '#000000'
set ytics textcolor rgbcolor '#000000'
set ylabel textcolor rgbcolor '#000000' 
set xlabel textcolor rgbcolor '#000000'
set cblabel textcolor rgbcolor '#000000'

#set style rect fc lt -1 fs solid 0.15 noborder
#set object 1 rect from 0,0 to 0.28,1 fc rgbcolor '#ffffff' front

set title "time interval from jet formation till impact / (T_{Rc}/100)"
 
plot  "contours_dt.dat" u 1:2 w l lc 0 not,\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(interval($9,$6,$1,$10)) w p pt 5 ps 2 palette t "",\
      inputfile u (rpstar($1,$3)):(dstar($1,$2)):(interval($9,$6,$1,$10)) w p pt 4 ps 2 lc 8 t ""
unset multiplot

!epstopdf jet_intervals.eps
!rm jet_intervals.eps

!rm interpolation_dt.txt contours_dt.dat












##########################################

set output "jet_Tcs.eps"

set palette maxcolors 40
set palette defined ( 0 '#0000ff',\
                      .6 '#bbbbbb',\
                      .8 '#aa0000',\
                      1.1 '#ff0000')
                      
set view map
set palette color
set pm3d corners2color mean
set contour surface
set surface
set dgrid3d 180,140,3
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*" norotate offset 2
set key above

#TRc(x) = 0.91468*Rmaxubd(x)*sqrt(998./101315.) # Rayleigh collapse time --- already defined above

inputfile2 = "jet_Tcs_save2021-10-15.dat"
rpstar2(Rn,rp) = rp/Rmaxubd(Rn)
dstar2(Rn,dinit) = dinit/Rmaxubd(Rn)


normTc(Rn,Tc)= Tc/(2.*TRc(Rn))
# 

#set cbrange [0.5:0.95]

set table "interpolation_Tc.txt"
splot inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normTc($1,$4)) 
unset table

set contour
unset surface
set cntrparam levels auto 15 # Modify this to your liking
set view map
unset clabel

set table "contours_Tc.dat"
splot inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normTc($1,$4)) notitle
unset table
unset contour

unset dgrid3d
unset contour
unset surface
unset pm3d
set palette color
set xrange [0.28:1]
set yrange [0:1]
set cbrange [*:*]

set multiplot
set xtics textcolor rgbcolor '#ffffff'
set ytics textcolor rgbcolor '#ffffff'
set ylabel textcolor rgbcolor '#ffffff'
set xlabel textcolor rgbcolor '#ffffff'
set cblabel textcolor rgbcolor '#ffffff'
set title ""
splot  "interpolation_Tc.txt" u 1:2:3 w image not  

set xtics textcolor rgbcolor '#000000'
set ytics textcolor rgbcolor '#000000'
set ylabel textcolor rgbcolor '#000000' 
set xlabel textcolor rgbcolor '#000000'
set cblabel textcolor rgbcolor '#000000'

#set style rect fc lt -1 fs solid 0.15 noborder
#set object 1 rect from 0,0 to 0.28,1 fc rgbcolor '#ffffff' front

set title "t(V_{min}) / (2 T_{Rc})"
 
plot  "contours_Tc.dat" u 1:2 w l lc 0 not,\
      inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normTc($1,$4)) w p pt 5 ps 2 palette t "",\
      inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normTc($1,$4)) w p pt 4 ps 2 lc 8 t ""
unset multiplot

!epstopdf jet_Tcs.eps
!rm jet_Tcs.eps

!rm interpolation_Tc.txt contours_Tc.dat













##########################################

set output "jet_Rmax.eps"

set palette maxcolors 40
set palette defined ( 0 '#0000ff',\
                      .6 '#bbbbbb',\
                      .8 '#aa0000',\
                      1.1 '#ff0000')
                      
set view map
set palette color
set pm3d corners2color mean
set contour surface
set surface
set dgrid3d 180,140,3
set xrange [*:1]

set xlabel "r_p^*"
set ylabel "D^*" norotate offset 2
set key above

#TRc(x) = 0.91468*Rmaxubd(x)*sqrt(998./101315.) # Rayleigh collapse time --- already defined above

## already defined above:
#inputfile2 = "jet_Tcs_save2021-10-15.dat"
#rpstar2(Rn,rp) = rp/Rmaxubd(Rn)
#dstar2(Rn,dinit) = dinit/Rmaxubd(Rn)
#normTc(Rn,Tc)= Tc/(2.*TRc(Rn))
normRmax(Rn,Rmax)= Rmax/Rmaxubd(Rn)


# 

#set cbrange [0.5:0.95]

set table "interpolation_Rmax.txt"
splot inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normRmax($1,$5)) 
unset table

set contour
unset surface
set cntrparam levels auto 15 # Modify this to your liking
set view map
unset clabel

set table "contours_Rmax.dat"
splot inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normRmax($1,$5)) notitle
unset table
unset contour

unset dgrid3d
unset contour
unset surface
unset pm3d
set palette color
set xrange [0.28:1]
set yrange [0:1]
set cbrange [*:1.01]

set multiplot
set xtics textcolor rgbcolor '#ffffff'
set ytics textcolor rgbcolor '#ffffff'
set ylabel textcolor rgbcolor '#ffffff'
set xlabel textcolor rgbcolor '#ffffff'
set cblabel textcolor rgbcolor '#ffffff'
set title ""
splot  "interpolation_Rmax.txt" u 1:2:3 w image not  

set xtics textcolor rgbcolor '#000000'
set ytics textcolor rgbcolor '#000000'
set ylabel textcolor rgbcolor '#000000' 
set xlabel textcolor rgbcolor '#000000'
set cblabel textcolor rgbcolor '#000000'

#set style rect fc lt -1 fs solid 0.15 noborder
#set object 1 rect from 0,0 to 0.28,1 fc rgbcolor '#ffffff' front

set title "R_{max,eq} / R_{max,unbound}"
 
plot  "contours_Rmax.dat" u 1:2 w l lc 0 not,\
      inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normRmax($1,$5)) w p pt 5 ps 2 palette t "",\
      inputfile2 u (rpstar2($1,$3)):(dstar2($1,$2)):(normRmax($1,$5)) w p pt 4 ps 2 lc 8 t ""
unset multiplot

!epstopdf jet_Rmax.eps
!rm jet_Rmax.eps

!rm interpolation_Rmax.txt contours_Rmax.dat
