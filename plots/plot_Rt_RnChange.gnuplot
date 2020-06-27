reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Rt.eps"
set grid
set ylabel "equiv. radius [{/Symbol m}m]"
set xlabel "t [{/Symbol m}s]"
set key top right #outside tmargin
set tics out

set xrange [0:130]



theta3  = system("cat ../conv_study_3mum_Econst_RnChange/THETA")/180.*pi
theta2  = system("cat ../conv_study_2mum_Econst_RnChange/THETA")/180.*pi
theta135= system("cat ../conv_study_1.35mum_Econst_RnChange/THETA")/180.*pi
theta12 = system("cat ../conv_study_1.2mum_Econst_RnChange/THETA")/180.*pi
theta1  = system("cat ../conv_study_1mum_Econst_RnChange/THETA")/180.*pi
theta075= system("cat ../conv_study_0.75mum_Econst_RnChange/THETA")/180.*pi

set multiplot

unset title 
#"cell size = 1e-06, R_0 = 2e-05, R_{n,start} = 0.0001841"

plot \
'../conv_study_3mum_Econst_RnChange/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                 using ((($1))*1e6):((($2)*3./(4.*theta3))**(1/3.)*1e6)   w l lw 3 lc 1 t "3{/Symbol m}m",\
'../conv_study_2mum_Econst_RnChange/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                 using ((($1))*1e6):((($2)*3./(4.*theta2))**(1/3.)*1e6)   w l lw 3 lc 2 t "2{/Symbol m}m",\
'../conv_study_1.35mum_Econst_RnChange/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                 using ((($1))*1e6):((($2)*3./(4.*theta135))**(1/3.)*1e6) w l lw 3 lc 3 t "1.35{/Symbol m}m",\
'../conv_study_1.2mum_Econst_RnChange/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                 using ((($1))*1e6):((($2)*3./(4.*theta12))**(1/3.)*1e6)  w l lw 3 lc 4 dt 3 t "1.2{/Symbol m}m",\
'../conv_study_1mum_Econst_RnChange/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                 using ((($1))*1e6):((($2)*3./(4.*theta1))**(1/3.)*1e6)   w l lw 3 lc 6 t "1{/Symbol m}m",\
'../conv_study_0.75mum_Econst_RnChange/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                 using ((($1))*1e6):((($2)*3./(4.*theta075))**(1/3.)*1e6) w l lw 3 lc 7 t "0.75{/Symbol m}m"
                 
     
unset xlabel
unset ylabel
unset key
unset grid
# clear
set origin .2,.2
set size .5,.5
set tics out
set xtics 99,0.5,101
set ytics 40
#set bmargin 0
#set tmargin 1
#set lmargin 1
#set rmargin 1
set xrange [99:*]
set object 1 rect from 90.5,0 to 105,200
set object 1 rect fc rgb 'white' fillstyle solid 0.0 noborder
replot
    
unset multiplot
