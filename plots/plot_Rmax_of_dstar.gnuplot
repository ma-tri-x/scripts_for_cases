reset

#set term x11
#set output

set term postscript eps color enhanced solid font "DejaVuSerif, 16"
set output "Rmax_of_dstar.eps"

set grid
set key above

set xrange [0:8.2]
set yrange [*:1]

set xlabel "D^*"
set ylabel "R_{max}/R_{max,unbound}"

set samples 1000

# set title  "R_{max,unbound} = 499.08{/Symbol m}m"

Rmaxunbound=494e-6 #499.08e-6
# 
# sigma=6.2
# epsilon=0.032
# q=sigma+0.1
# off=0.984
# # g(x) = -0.04*exp(-(x-0.00)**2/2./0.005**2)
# f(x)=4.*epsilon*((sigma/(x+q))**12 - (sigma/(x+q))**6)+1 #+ g(x)
# #fit [0.03:*] f(x) "Rmax_of_dstar_new.dat" u 1:(($2)/Rmaxunbound) via sigma,epsilon,b



a=0.958
b=0.6
k(x) = (1-(1-a)*exp(-b*x))
fit [0.4:*] k(x) "Rmax_of_dstar_new.dat" u 1:(($2)/Rmaxunbound) via a,b

c=0.968
d=14.0
l(x)= c+(1-c)*exp(-d*(x-0.04))
fit [0.04:0.4] l(x) "Rmax_of_dstar_new.dat" u 1:(($2)/Rmaxunbound) via c,d
m(x)= 0.968 + (1-0.968)/0.04*x

arb(x)=x>0 && x<0.04? m(x) : (x<0.4? l(x) : k(x))

set multiplot

p \
"Rmax_of_dstar_new.dat" u 1:(($2)/Rmaxunbound) w p ps 3 lw 5 t "R_{max} from numerical data",\
arb(x) lw 3 t "R_{max}(D^*) arbitrary fit"

set origin .45, .2
set size .4,.4
clear
unset key
# unset grid
unset ylabel
unset xlabel
unset object
unset arrow
unset title
# set xtics .1
set ytics .01
set bmargin 1
set tmargin 1
set lmargin 3
set rmargin 1
set xrange [0:0.6]
replot
unset multiplot

!epstopdf Rmax_of_dstar.eps
!rm Rmax_of_dstar.eps
!pdfcrop Rmax_of_dstar.pdf Rmax_of_dstar.pdf
