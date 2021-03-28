#!/bin/gnuplot

reset
# set term wxt
# set output
set term postscript eps color enhanced solid font "DejaVuSerif, 24"
set output "jet_speed.eps"

set grid
set key  bottom left
set multiplot
set xrange[98:101]

set xlabel "t [{/Symbol m}s]"
#set ylabel "min({/Symbol a}_1^.U_y) [m/s]"
set ylabel "{/Italic v_j} [m/s]"

 set arrow from 100.4, graph 0 to 100.4, graph 1 nohead lw 2 lc 7
 set arrow from 100.2, graph 0 to 100.2, graph 1 nohead lw 2 lc rgbcolor "0x0000FF"
 set arrow from 100.05, graph 0 to 100.05, graph 1 nohead lw 2 lc 3
 set arrow from 99.76, graph 0 to 99.76, graph 1 nohead lw 2 lc 2
 set arrow from 99.2, graph 0 to 99.2, graph 1 nohead lw 2 lc 8
 

plot \
 "../conv_study_0.75mum_SolidBoundary_polar_low_res/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lw 7 lc 7 t "0.75{/Symbol m}m", "../conv_study_1mum_SolidBoundary_polar_low_res/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lw 3 lc rgbcolor "0x0000FF" dt 1 t "1{/Symbol m}m", "../conv_study_1.35mum_SolidBoundary_polar_low_res/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lw 3 lc 3 dt 1 t "1.35{/Symbol m}m", "../conv_study_2mum_SolidBoundary_polar_low_res/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lw 5 lc 2 dt 1 t "2{/Symbol m}m", "../conv_study_3mum_SolidBoundary_polar_low_res/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lw 3 lc 8 dt 1 t "3{/Symbol m}m" 
    
#UNCOMMENTFORINSETunset xlabel
#UNCOMMENTFORINSETunset ylabel
#UNCOMMENTFORINSETunset key
#UNCOMMENTFORINSETset grid
#UNCOMMENTFORINSET# clear
#UNCOMMENTFORINSETset origin .15,.2
#UNCOMMENTFORINSETset size .4,.4
#UNCOMMENTFORINSETset tics out
#UNCOMMENTFORINSETset xtics INSETXTICS font ",18"
#UNCOMMENTFORINSETset ytics 20
#UNCOMMENTFORINSET#set bmargin 0
#UNCOMMENTFORINSET#set tmargin 1
#UNCOMMENTFORINSET#set lmargin 1
#UNCOMMENTFORINSET#set rmargin 1
#UNCOMMENTFORINSETset xrange [INSETRANGE]
#UNCOMMENTFORINSETset object 1 rect from 90.5,-200 to 105,-70
#UNCOMMENTFORINSETset object 1 rect fc rgb 'white' fillstyle solid 0.0 noborder
#UNCOMMENTFORINSETreplot
    
unset multiplot
