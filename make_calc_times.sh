#!/bin/bash

# echo "" > calc_times2.dat
# for i in ../0071_dstar1.6_from_sose2019_boxBubble*;do
#     echo $i >> calc_times2.dat
#     tail -n 12 $i/run.log >> calc_times2.dat
# done
# echo "calc_times2.dat still needs to be altered manually"

gnuplot plot_calc_times.gnuplot
epstopdf calc_times_box.eps
rm calc_times_box.eps
pdfcrop calc_times_box.pdf calc_times_box.pdf
