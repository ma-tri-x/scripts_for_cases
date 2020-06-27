reset
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Rt.eps"
set grid
set ylabel "equiv. radius [{/Symbol m}m]"
set xlabel "t [{/Symbol m}s]"
set key top right #outside tmargin
set tics out

set xrange [0:130]


set multiplot

unset title 

plot \
 "../sp_conv_study_3mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.0145444104332861) )**2))**(1/3.)*1e6) w l lw 3   t "3{/Symbol m}m", "../sp_conv_study_2mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.0098174770424681) )**2))**(1/3.)*1e6) w l lw 3   t "2{/Symbol m}m", "../sp_conv_study_1.35mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.00665591663896143) )**2))**(1/3.)*1e6) w l lw 3   t "1.35{/Symbol m}m", "../sp_conv_study_1mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.00490873852123405) )**2))**(1/3.)*1e6) w l lw 3   t "1{/Symbol m}m", "../sp_conv_study_0.6mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.0029526246744265) )**2))**(1/3.)*1e6) w l lw 3 lc 3 dt 2 t "0.6{/Symbol m}m", "../sp_conv_study_0.4mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.00196349540849362) )**2))**(1/3.)*1e6) w l lw 3   t "0.4{/Symbol m}m", "../sp_conv_study_0.2mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.00098174770424681) )**2))**(1/3.)*1e6) w l lw 3   t "0.2{/Symbol m}m", "../sp_conv_study_0.1mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.000490873852123405) )**2))**(1/3.)*1e6) w l lw 3   t "0.1{/Symbol m}m", "../sp_conv_study_0.05mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(0.000245436926061703) )**2))**(1/3.)*1e6) w l lw 3 dt 2 t "0.05{/Symbol m}m", "../sp_conv_study_0.02mum/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2" using (($1)*1e6):((($2)*3./(4.*( tan(9.8174770424681e-05) )**2))**(1/3.)*1e6) w l lw 3 dt 2 t "0.02{/Symbol m}m"

                 
                 
unset xlabel
unset ylabel
unset key
unset grid
# clear
set origin .2,.2
set size .5,.5
set tics out
set xtics 91,0.5
set ytics 40
#set bmargin 0
#set tmargin 1
#set lmargin 1
#set rmargin 1
set xrange [91:92.5]
set object 1 rect from 90.5,0 to 105,200
set object 1 rect fc rgb 'white' fillstyle solid 0.0 noborder
replot
    
unset multiplot
