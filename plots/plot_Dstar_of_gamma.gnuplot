reset

#set term x11
#set output
set term postscript eps color enhanced solid font "DejaVuSerif, 20"
set output "Dstar_of_gamma.eps"

set grid
set key above

set xrange [0:3.2]
set yrange [*:*]

set xlabel "{/Symbol g}_d"
set ylabel "D^*"

set samples 1000

set size ratio -1

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
h(x)=c*x + d
fit h(x) "Rmax_of_dinit.dat" u (($2)/($3)):(($2)/Rmaxunbound) via c,d
p \
"Rmax_of_dinit.dat" u (($2)/($3)):(($2)/Rmaxunbound) w p ps 3 lw 2 t "numerical data" ,\
h(x) t sprintf("   %.4f {/Symbol g}_d  %.4f", c,d)

!epstopdf Dstar_of_gamma.eps
!rm Dstar_of_gamma.eps
!pdfcrop Dstar_of_gamma.pdf Dstar_of_gamma.pdf
