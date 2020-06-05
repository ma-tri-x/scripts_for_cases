#!/bin/bash

thisdir=$(pwd)

get_Rn ()
{
    echo "$(python <<< "print(\"${1}\".split(\"Rn\")[-1].split(\"mum\")[0])")"
}

get_dinit ()
{
    echo "$(python <<< "print(\"${1}\".split(\"dinit\")[-1].split(\"mum\")[0])")"
}

study_cases=" \
../kk010_piston_axi_static_Rn184.1mum_dinit30mum \
../kk010_piston_axi_static_Rn240.0mum_dinit30mum \
../kk010_piston_axi_static_Rn184.1mum_dinit90mum \
../kk010_piston_axi_static_Rn201.5mum_dinit90mum \
../kk010_piston_axi_static_Rn240.0mum_dinit90mum \
../kk010_piston_axi_static_Rn184.1mum_dinit150mum \
../kk010_piston_axi_static_Rn201.5mum_dinit150mum \
../kk010_piston_axi_static_Rn240.0mum_dinit150mum \
"

echo "python rendering sucks because it doesnt rescale and use the layout from the pvsm"
# exit 0

# echo "render again? [y/n]: "
# read bla

for i in $study_cases;do
    Rn=$(get_Rn $i)
    dinit=$(get_dinit $i)
    #ofstring=kk010_mushroom_Rn${Rn}_dinit${dinit}
    cp states/kk010_mushrooms_diagnose.pvsm.backup $i/states/kk010_mushrooms_diagnose_thisdir.pvsm
    cd $i
#     if [ "$bla" = "y" ];then
#         mkdir -p anim
#         #rm anim/*.png
#         cp $thisdir/states/kk010_mushrooms_diagnose.pvsm.backup states/kk010_mushrooms_diagnose.pvsm
#         sed -i "s/textreplace/R_n=${Rn}µm,D_init=${dinit}µm/g" states/kk010_mushrooms_diagnose.pvsm
#         echo "rendering $i"
#         python render_timestep_via_pvsm_V4.py -p processor0 -dt 0.0 -a 0.0 -b 1.0 -s states/kk010_mushrooms_diagnose.pvsm -o anim/${ofstring} -w r > log.render 2>&1
#     fi
    sed -i "s#textreplace#R_n=${Rn}um,D_init=${dinit}um#g" states/kk010_mushrooms_diagnose_thisdir.pvsm
    sed -i "s#TEMPLATENAME#$(basename $(pwd)).foam#g" states/kk010_mushrooms_diagnose_thisdir.pvsm
    sed -i "s#TEMPLATEDIR#$(pwd)/$(basename $(pwd)).foam#g" states/kk010_mushrooms_diagnose_thisdir.pvsm
    paraFoam
#     echo "ffmpeg on $i"
#     ffmpeg -pattern_type sequence -framerate 15 -i anim/${ofstring}.%d.png -b:v 5M -c:v mpeg4 anim/${ofstring}.avi > log.ffmpeg 2>&1
#     cp anim/*.avi $thisdir
    cd $thisdir
#     exit 0
done
