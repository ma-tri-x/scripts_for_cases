reset

set isosample 150, 150
unset surface
set contour base
#set cntrlabel onecolor format '%8.3g' font ',6' 
#start 80 interval 20
#set cntrparam levels increment 85,3,115
set table "cont.dat"
splot "amplitudes_results_0.5um.dat" u (($1)/1e3):(($2)/1e6):(($3)*1e3)
unset table

reset

set term qt font "DejaVuSerif, 16"
set output

unset grid 
# set key above
unset key

set xlabel "p_{atm} [kPa]"
set ylabel "p_{ac} [MPa]"
set cblabel "R_{max} [mm]"

set pm3d 
unset surface
set palette
set view map
l '<python3 alter_contour_file.py -w 1 -f 16' # loads the output to gnuplot "set label bla at x,y centre front"
p "amplitudes_results_0.5um.dat" u (($1)/1e3):(($2)/1e6):(($3)*1e3) w image,\
  "altered_cont.dat" w l lw 3 lt 8 not
  
  
#   "cont.dat" w l lt -1 lw 2
#   '<./cont.sh cont.dat 1 15 0' w l lt -1 lw 1.5
# ,\
#       "amplitudes_results.dat" u (($1)/1e6):(($2)/1e6):(($3)*1e3) w labels t ""

pause -1
#   
set term postscript eps color enhanced solid font "DejaVuSerif, 18"
set output "Rmax_Rn0.4um_ChurchProfile_gilmore.eps"
replot

!epstopdf Rmax_Rn0.4um_ChurchProfile_gilmore.eps
!rm Rmax_Rn0.4um_ChurchProfile_gilmore.eps
!pdfcrop Rmax_Rn0.4um_ChurchProfile_gilmore.pdf Rmax_Rn0.4um_ChurchProfile_gilmore.pdf
