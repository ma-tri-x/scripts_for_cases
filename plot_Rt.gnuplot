reset
set term postscript eps color enhanced solid font "DejaVuSerif, 24"
set output "Rt.eps"
set grid
set ylabel "equiv. radius [{/Symbol m}m]"
set xlabel "t [{/Symbol m}s]"
set key top right #outside tmargin
set tics out

set xrange [0:130]
#x=cellsize!
Xi=80e-6
Anum(x)=Xi/x
Bnum90deg(x)=2*Anum(x)
thet(x)=90./Bnum90deg(x)/2.
theta(x)=thet(x)/180.*pi

set multiplot

unset title 
#"cell size = 1e-06, R_0 = 2e-05, R_{n,start} = 0.0001841"

plot \
'../0071_dstar1.6_from_sose2019_boxBubble/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                           using ((($1))*1e6):((($2)*3./(4.*theta(1e-6)))**(1/3.)*1e6) w l lw 3 lc 1 t "1{/Symbol m}m",\
'../0071_dstar1.6_from_sose2019_boxBubble_1.5mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                           using ((($1))*1e6):((($2)*3./(4.*theta(1.5e-6)))**(1/3.)*1e6) w l lw 3 lc 2 t "1.5{/Symbol m}m",\
'../0071_dstar1.6_from_sose2019_boxBubble_2mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2' \
                           using ((($1))*1e6):((($2)*3./(4.*theta(2e-6)))**(1/3.)*1e6) w l lw 5 lc 3 t "2{/Symbol m}m"
     
unset xlabel
unset ylabel
unset key
unset grid
# clear
set origin .2,.2
set size .5,.5
set tics out
set xtics 98,1,101
set ytics 40
#set bmargin 0
#set tmargin 1
#set lmargin 1
#set rmargin 1
set xrange [98:*]
set object 1 rect from 90.5,0 to 105,200
set object 1 rect fc rgb 'white' fillstyle solid 0.0 noborder
replot
    
unset multiplot
