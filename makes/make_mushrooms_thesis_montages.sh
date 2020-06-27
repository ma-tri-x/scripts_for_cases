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

split_string () {
    string=$1
    split=$2
    index=$3
    echo "$(python <<< "print(\"${string}\".split(\"${split}\")[${index}])")"
}

process_study_case () {
    study_case=$1
    fr1=$2
    fr2=$3
    fr3=$4
    fr4=$5
    name_raw=$(ls $study_case/anim/*_thesis2.0350.png)
    name_ra=$(split_string $name_raw / -1)
    name=$(split_string $name_ra ".0350.png" 0)
    Rn=$(get_Rn $study_case)
    dinit=$(get_dinit $study_case)
    frames=" \
    $study_case/anim/${name}.${fr1}.png \
    $study_case/anim/${name}.${fr2}.png \
    $study_case/anim/${name}.${fr3}.png \
    $study_case/anim/${name}.${fr4}.png \
    "
    of=$study_case/montage_${name}.jpg
    echo $of
    montage $frames -geometry +5+5 -tile 4 $of
    cp $of .
}

study_case="../kk010_piston_axi_static_Rn184.1mum_dinit30mum"
process_study_case $study_case 0277 0303 0344 0400

study_case="../kk010_piston_axi_static_Rn201.5mum_dinit30mum"
process_study_case $study_case 0255 0270 0344 0400

study_case="../kk010_piston_axi_static_Rn240.0mum_dinit30mum"
process_study_case $study_case 0260 0285 0344 0400
exit 0

study_case="../kk010_piston_axi_static_Rn184.1mum_dinit90mum"
process_study_case $study_case 0277 0303 0344 0400

study_case="../kk010_piston_axi_static_Rn201.5mum_dinit90mum"
process_study_case $study_case 0277 0303 0344 0400

study_case="../kk010_piston_axi_static_Rn240.0mum_dinit90mum"
process_study_case $study_case 0277 0303 0344 0400

study_case="../kk010_piston_axi_static_Rn184.1mum_dinit150mum"
process_study_case $study_case 0277 0303 0344 0400

study_case="../kk010_piston_axi_static_Rn201.5mum_dinit150mum"
process_study_case $study_case 0277 0303 0344 0400

study_case="../kk010_piston_axi_static_Rn240.0mum_dinit150mum"
process_study_case $study_case 0277 0303 0344 0400
