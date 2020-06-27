#!/bin/gnuplot

reset
# set term wxt
# set output
set term postscript eps color enhanced solid font "DejaVuSerif, 24"
set output "jet_speed.eps"

set grid

set multiplot
set xrange[90:*]

set xlabel "t [{/Symbol m}s]"
set ylabel "min(U_y) [m/s]"

plot \
"../0071_dstar1.6_from_sose2019_boxBubble_2mum/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lw 3 lc 1 dt 1 t "1{/Symbol m}m" ,\
"../0071_dstar1.6_from_sose2019_boxBubble/postProcessing/swakExpression_extremeUy/0/extremeUy"      u (($1)*1e6):2 w l lw 5 lc 2 dt 1 t "2{/Symbol m}m"
    
    #"../0071_dstar1.6_from_sose2019_2mum/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lc 6 t "2{/Symbol m}m" 
    #"../0071_dstar1.6_from_sose2019_3mum/postProcessing/swakExpression_extremeUy/0/extremeUy" u (($1)*1e6):2 w l lc 7 t "3{/Symbol m}m"
# dt 5
# dt 4
# dt 3
# dt 2
# dt 1    
    
unset xlabel
unset ylabel
unset key
unset grid
# clear
set origin .15,.2
set size .4,.4
set tics out
set xtics 99,1,101
set ytics 20
#set bmargin 0
#set tmargin 1
#set lmargin 1
#set rmargin 1
set xrange [99:*]
set object 1 rect from 90.5,-150 to 105,-70
set object 1 rect fc rgb 'white' fillstyle solid 0.0 noborder
replot
    
unset multiplot
#!epstopdf --autorotate=None jet_speed.eps
#!rm jet_speed.eps
#!pdfcrop jet_speed.pdf jet_speed.pdf
