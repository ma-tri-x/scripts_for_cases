#!/bin/bash

thisdir=$(pwd)

get_dstar ()
{
    echo "$(python <<< "print(\"${1}\".split(\"_\")[-1])")"
}

dstar_cases=" \
../dstar_0.2 \
../dstar_0.4 \
../dstar_0.6 \
../dstar_0.8 \
../dstar_1.0 \
../dstar_1.2 \
../dstar_1.4 \
../dstar_1.6 \
../dstar_1.8 \
"
dstar_cases=" \
../noWallRefine_dstar_1.29 \
../noWallRefine_dstar_1.30 \
../noWallRefine_dstar_1.31 \
../noWallRefine_dstar_1.32 \
../noWallRefine_dstar_1.33 \
"

for i in $dstar_cases;do
    echo $i
    cp $thisdir/render_inkmaps.py $i
    cp $thisdir/states/inkmap_axisymm*.pvsm* $i/states/
    cd $i
    #statefile=states/inkmap_axisymm_lagrangianInk_vorticity_withText_for_manual_edit_V2.pvsm
    statefile=states/inkmap_axisymm_lagrangianInk_vorticity_withText_for_manual_edit_V3_zoom.pvsm
    sed -i "s/D\*=/D\*=$(get_dstar $i)/g" $statefile
    sed -i "s/dstar_0.2/${i#../}/g" $statefile
    echo "python render_inkmaps.py ## \
          python API just sucks. It's almost cool. \
          But only almost. That's why we do it manually"
    paraFoam
    cp *.png $thisdir
    cd $thisdir
    #exit 0
done

bash convert_all_png_to_jpg.sh
bash crop_all_jpg.sh
