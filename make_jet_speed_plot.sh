#!/bin/bash

gnuplot plot_jet_speed.gnuplot
epstopdf jet_speed.eps
rm jet_speed.eps
pdfcrop jet_speed.pdf jet_speed_box.pdf
rm jet_speed.pdf
# pdf270 jet_speed.pdf
# mv jet_speed-rotated270.pdf jet_speed.pdf
