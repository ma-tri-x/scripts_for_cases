reset

set term x11
set output

#set term postscript eps color enhanced solid font "DejaVuSerif, 20"
#set output "Rmax_of_gamma.eps"

set grid
set key above

set xrange [0:3.2]
set yrange [*:*]

set xlabel "{/Symbol g}_d"
set ylabel "R_{max}/R_{max,unbound}"

set samples 1000

Rmaxunbound=499.08e-6
sigma=3.2
epsilon=0.025
b=sigma-.05
off=0.984
g(x) = -0.04*exp(-(x-0.00)**2/2./0.005**2)
f(x)=4.*epsilon*((sigma/(x+b))**12 - (sigma/(x+b))**6)+off + g(x)
# f(x) = -tanh(a*x)* exp(-b*x) + 1
# f(x) = (0.958+0.00105*x)+(0.00105*x**3*exp(-1*x**2))
#f(x) = 1-b*exp(-(x-0.335)**2/2./a**2)*(x-c)
#fit [0.01:*] f(x) "Rmax_of_dinit.dat" u (($2)/($3)):(($2)/Rmaxunbound) via epsilon,sigma,b

p \
"Rmax_of_dinit.dat" u (($2)/($3)):(($3)/Rmaxunbound) w p ps 3 lw 5 t "numerical data",\
f(x) t "Lennard-Jones potential function"
