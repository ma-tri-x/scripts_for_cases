#!/bin/bash
#example call
#/home/koch/Programme/blender-2.79b-linux-glibc219-x86_64/blender --background --python render_bubble.py -- -f 0079_storage_all_ts0.0.stl -t template_for_luft_blase24.blend -x 385 -y 575
echo "" > log.renderBlender

for i in stl_data/*.stl
do
	echo $i
	f=$i 
	blender --background --python render_bubble_inside_cuvette_V4.py -- -f $f -t render_kk004.blend -s "" -x 385 -y 575 >> log.renderBlender2
done

