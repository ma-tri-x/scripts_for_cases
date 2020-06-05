#!/bin/bash

gnuplot plot_vortex_fabian_results.gnuplot
convert -trim MKFabiansDiagramm.png MKFabiansDiagramm.jpg
