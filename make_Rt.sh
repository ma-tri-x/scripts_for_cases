#!/bin/bash

gnuplot plot_Rt.gnuplot
epstopdf Rt.eps
pdfcrop Rt.pdf Rt_box.pdf
rm Rt.pdf
