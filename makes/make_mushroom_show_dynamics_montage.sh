#!/bin/bash

dir=~/Desktop/foamProjects/kk010_piston_axi_static_Rn184.1mum_dinit90mum/anim

files1=" \
$dir/kk010_show_dynamics.0020.png \
$dir/kk010_show_dynamics.0050.png \
$dir/kk010_show_dynamics.0150.png \
\
$dir/kk010_show_dynamics.0250.png \
$dir/kk010_show_dynamics.0320.png \
$dir/kk010_show_dynamics.0350.png \
\
$dir/kk010_show_dynamics.0360.png \
$dir/kk010_show_dynamics.0370.png \
$dir/kk010_show_dynamics.0378.png \
"
files2=" \
$dir/kk010_show_dynamics.0385.png \
$dir/kk010_show_dynamics.0395.png \
$dir/kk010_show_dynamics.0450.png \
\
$dir/kk010_show_dynamics.0490.png \
$dir/kk010_show_dynamics.0510.png \
$dir/kk010_show_dynamics.0550.png \
\
$dir/kk010_show_dynamics.0580.png \
$dir/kk010_show_dynamics.0610.png \
$dir/kk010_show_dynamics.0650.png \
"

# $dir/kk010_show_dynamics.0100.png \
# $dir/kk010_show_dynamics.0480.png \
# $dir/kk010_show_dynamics.0500.png \


montage $files1 -geometry +5+5 -tile 3 $dir/montage_mushroom_show_dynamics.jpg
montage $files2 -geometry +5+5 -tile 3 $dir/montage_mushroom_show_dynamics2.jpg
cp $dir/montage_mushroom_show_dynamics*.jpg .
