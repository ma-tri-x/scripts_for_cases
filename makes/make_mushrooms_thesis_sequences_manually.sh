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
../kk010_piston_axi_static_Rn201.5mum_dinit30mum \
../kk010_piston_axi_static_Rn240.0mum_dinit30mum \
"
next_time=" \
../kk010_piston_axi_static_Rn184.1mum_dinit90mum \
../kk010_piston_axi_static_Rn201.5mum_dinit90mum \
../kk010_piston_axi_static_Rn240.0mum_dinit90mum \
../kk010_piston_axi_static_Rn184.1mum_dinit150mum \
../kk010_piston_axi_static_Rn201.5mum_dinit150mum \
../kk010_piston_axi_static_Rn240.0mum_dinit150mum \
../kk010_piston_axi_static_Rn184.1mum_dinit250mum \
../kk010_piston_axi_static_Rn201.5mum_dinit250mum \
../kk010_piston_axi_static_Rn240.0mum_dinit250mum \
"


echo "python rendering sucks because it doesnt rescale and use the layout from the pvsm"


# backup=states/kk010_mushrooms_thesis.pvsm.backup
backup=states/kk010_mushrooms_show_dynamics.pvsm.backup
dest=states/kk010_mushrooms_show_dynamics_thesis_thisdir.pvsm

for i in $study_cases;do
#     Rn=$(get_Rn $i)
#     dinit=$(get_dinit $i)
    cp $backup $i/$dest
    cd $i
    sed -i "s#TEMPLATENAME#$(basename $(pwd)).foam#g" $dest
    sed -i "s#TEMPLATEDIR#$(pwd)/$(basename $(pwd)).foam#g" $dest
    paraFoam
    cd $thisdir
done
