#!/bin/bash
#example call
#/home/koch/Programme/blender-2.79b-linux-glibc219-x86_64/blender --background --python render_bubble.py -- -f 0079_storage_all_ts0.0.stl -t template_for_luft_blase24.blend -x 385 -y 575
echo "" > log.renderBlender

blender_file=/home/shir/2020SoSe/EXP/2020-08-19_01_the_jet_again/big_cuvette.blend
move_bubble_x=0
move_bubble_y=0
move_bubble_z=20.792

for i in stl_data/*.stl
do
	echo $i
	f=$i 
	blender --background --python render_bubble_inside_cuvette_V5.py -- -f $f -t $blender_file -l true \
	-s "" -x 575 -y 385 -mx $move_bubble_x -my $move_bubble_y -mz $move_bubble_z  >> log.renderBlender2
done

