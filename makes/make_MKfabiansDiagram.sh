#!/bin/bash

get_dstar ()
{
    echo "$(python <<< "print(\"${1}\".split(\"_\")[-1])")"
}

study_cases=" \
../dstar_0.2 \
../noWallRefine_dstar_0.4 \
../noWallRefine_dstar_0.42 \
../dstar_0.6 \
../dstar_0.8 \
../dstar_1.0 \
../dstar_1.2 \
../dstar_1.4 \
../dstar_1.6 \
../dstar_1.8 \
"

gnuplot plot_vortex_fabian_results.gnuplot
convert -trim MKFabiansDiagramm.png MKFabiansDiagramm.jpg
