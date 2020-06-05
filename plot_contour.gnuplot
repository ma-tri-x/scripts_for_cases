#!/bin/gnuplot

reset
#set term wxt
#set output

set term pngcairo transparent font "DejaVuSerif, 18pt" size 1000,900 #postscript enhanced solid color font "DejaVuSerif, 18pt"
set output "contour.png" #"contour.eps"
#  set key above #top left
# # unset key
set key above
set size ratio -1
set tics out
set grid lw 3
set datafile separator ","



#autofreq start,incr:
## set ylabel "y [{/Symbol m}m]"
## set xlabel "x [{/Symbol m}m]"
## set xtics autofreq 100
## set ytics autofreq 100
set ylabel "y [{/Symbol m}m]"
set xlabel "x [{/Symbol m}m]"
set xtics autofreq 100
set ytics autofreq 100

# set xtics autofreq 0,100 
# unset ylabel
# unset xlabel
# set format y ""

set xrange [-350:350]
set yrange [-30:500]

dir1 = "../kk010_piston_axi_static_3mum/"
time_theory_1 = system(sprintf("python %sget_time_of_radius.py -r %f -t %f -e 101e-6",dir1,radius,start_time))
time_1 = system(sprintf("python %sget_closest_timestep.py -p processor0 -t %s",dir1,time_theory_1))
time_idx_1 = system(sprintf("python %sget_index_of_time.py %s",dir1,time_1))
file1=sprintf("bla0.%s.csv",time_idx_1 )

dir2 = "../kk010_piston_axi_static/"
time_theory_2 = system(sprintf("python %sget_time_of_radius.py -r %f -t %f -e 104.3e-6",dir2,radius,start_time))
time_2 = system(sprintf("python %sget_closest_timestep.py -p processor0 -t %s",dir2,time_theory_2))
time_idx_2 = system(sprintf("python %sget_index_of_time.py %s",dir2,time_2))
file2=sprintf("bla0.%s.csv",time_idx_2)

dir3 = "../kk010_piston_axi_static_0.75mum/"
time_theory_3 = system(sprintf("python %sget_time_of_radius.py -r %f -t %f -e 104.5e-6",dir3,radius,start_time))
time_3 = system(sprintf("python %sget_closest_timestep.py -p processor0 -t %s",dir3,time_theory_3))
time_idx_3 = system(sprintf("python %sget_index_of_time.py %s",dir3,time_3))
file3=sprintf("bla0.%s.csv",time_idx_3)

dir4 = "../kk010_piston_axi_static_1mum/"
time_theory_4 = system(sprintf("python %sget_time_of_radius.py -r %f -t %f -e 104.5e-6",dir4,radius,start_time))
time_4 = system(sprintf("python %sget_closest_timestep.py -p processor0 -t %s",dir4,time_theory_4))
time_idx_4 = system(sprintf("python %sget_index_of_time.py %s",dir4,time_4))
file4=sprintf("bla0.%s.csv",time_idx_4)

dir5 = "../kk010_piston_axi_static_0.65mum/"
time_theory_5 = system(sprintf("python %sget_time_of_radius.py -r %f -t %f -e 104.5e-6",dir5,radius,start_time))
time_5 = system(sprintf("python %sget_closest_timestep.py -p processor0 -t %s",dir5,time_theory_5))
time_idx_5 = system(sprintf("python %sget_index_of_time.py %s",dir5,time_5))
file5=sprintf("bla0.%s.csv",time_idx_5)

dir6 = "../kk010_piston_axi_static_1.2mum/"
time_theory_6 = system(sprintf("python %sget_time_of_radius.py -r %f -t %f -e 104.5e-6",dir6,radius,start_time))
time_6 = system(sprintf("python %sget_closest_timestep.py -p processor0 -t %s",dir6,time_theory_6))
time_idx_6 = system(sprintf("python %sget_index_of_time.py %s",dir6,time_6))
file6=sprintf("bla0.%s.csv",time_idx_6)

plot \
dir5."contour/".file5 u ( ($2)*1e6):(($3)*1e6) w l lw 7 lc 7 dt 1 t "0.65{/Symbol m}m",\
dir5."contour/".file5 u (-($2)*1e6):(($3)*1e6) w l lw 7 lc 7 dt 1 notitle ,\
dir2."contour/".file2 u ( ($2)*1e6):(($3)*1e6) w l lw 3 lc 1 dt 1 t "1.5{/Symbol m}m",\
dir6."contour/".file6 u ( ($2)*1e6):(($3)*1e6) w l lw 3 lc 2 dt 1 t "1.2{/Symbol m}m",\
dir4."contour/".file4 u (-($2)*1e6):(($3)*1e6) w l lw 3 lc 3 dt 1 t "1{/Symbol m}m",\
dir3."contour/".file3 u ( ($2)*1e6):(($3)*1e6) w l lw 3 lc 4 dt 1 t "0.75{/Symbol m}m"

#dir1."contour/".file1 u ( ($2)*1e6):(($3)*1e6) w l lw 3 lc 1 dt 1 t "3{/Symbol m}m",\
