#!/bin/bash

gnuplot plot_initial_pVgamma.gnuplot
epstopdf initial_pVgamma.eps
pdfcrop initial_pVgamma.pdf initial_pVgamma.pdf
rm initial_pVgamma.eps
