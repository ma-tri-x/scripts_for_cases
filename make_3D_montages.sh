#!/bin/bash

thisdir=$(pwd)

dir1=/storage/BERLIN_STORAGE/2019WiSe2020/foamProjects/b012_3D_piston_simple_mesh/anim
dir2=/storage/BERLIN_STORAGE/2019WiSe2020/foamProjects/b013_3D_piston_simple_mesh/anim

max1=0112
max2=0104

files1=" \
$dir1/b013_mushroom_3D_anim05.0010.png \
$dir1/b013_mushroom_3D_anim05.0019.png \
$dir1/b013_mushroom_3D_anim05.0025.png \
\
$dir1/b013_mushroom_3D_anim04.0028.png \
$dir1/b013_mushroom_3D_anim04.0034.png \
$dir1/b013_mushroom_3D_anim04.0035.png \
\
$dir1/b013_mushroom_3D_anim04.0040.png \
$dir1/b013_mushroom_3D_anim04.0050.png \
$dir1/b013_mushroom_3D_anim04.0060.png \
\
$dir1/b013_mushroom_3D_anim05.0070.png \
$dir1/b013_mushroom_3D_anim05.0095.png \
$dir1/b013_mushroom_3D_anim05.0100.png \
"

files2=" \
$dir2/b013_mushroom_3D_anim03.0010.png \
$dir2/b013_mushroom_3D_anim03.0020.png \
$dir2/b013_mushroom_3D_anim03.0035.png \
\
$dir2/b013_mushroom_3D_anim02.0040.png \
$dir2/b013_mushroom_3D_anim02.0045.png \
$dir2/b013_mushroom_3D_anim02.0049.png \
\
$dir2/b013_mushroom_3D_anim02.0052.png \
$dir2/b013_mushroom_3D_anim02.0060.png \
$dir2/b013_mushroom_3D_anim02.0069.png \
\
$dir2/b013_mushroom_3D_anim03.0090.png \
$dir2/b013_mushroom_3D_anim03.0095.png \
$dir2/b013_mushroom_3D_anim03.0104.png \
"


montage $files1 -geometry +5+5 -tile 3 b012_3D_montage.jpg
montage $files2 -geometry +5+5 -tile 3 b013_3D_montage.jpg
