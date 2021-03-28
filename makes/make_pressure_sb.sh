#!/bin/bash

thisdir=$(pwd)
plotfile=plot_pressure_sb.gnuplot

get_y_sb () {
line=$(grep "max (1" system/snappyHexMeshDict)
python <<< "print(\"${line}\".split(\"max (1\")[-1].split(\" 1);\")[0])"
}

get_dstar () {
dir=$1
python <<< "print(\"${dir}\".split(\"dstar_\")[-1].split(\"_\")[0])"
}

append_to_gnuplot_script (){
dir_to_pressure_file=$1 
usage=$2
title=$3
echo "p \"$dir_to_pressure_file\" u $usage t \"$title\"" >> $thisdir/$plotfile
}

# study_cases="
# ../dstar_0.0 \
# ../dstar_0.1 \
# ../dstar_0.2 \
# ../dstar_0.4 \
# ../dstar_0.6 \
# ../dstar_0.8 \
# ../dstar_1.0 \
# ../dstar_1.2 \
# ../dstar_1.4 \
# ../dstar_1.6 \
# ../dstar_1.8 \
# ../dstar_3.0 \
# ../dstar_3.0_Rn400mu \
# ../dstar_8.0 \
# ../noWallRefine_dstar_0.4 \
# ../noWallRefine_dstar_0.42 \
# ../noWallRefine_dstar_0.4_tTransitStart90mus \
# ../noWallRefine_dstar_1.29 \
# ../noWallRefine_dstar_1.30 \
# ../noWallRefine_dstar_1.31 \
# ../noWallRefine_dstar_1.32 \
# ../noWallRefine_dstar_1.33 \
# "
study_cases1=" \
../dstar_0.0_probed \
../dstar_0.1_probed \
../dstar_0.2_probed \
../noWallRefine_dstar_0.4_probed \
../noWallRefine_dstar_0.42_probed \
../dstar_0.6_probed \
"

study_cases2=" \
../dstar_0.8_probed \
../dstar_1.0_probed \
../dstar_1.2_probed \
../noWallRefine_dstar_1.30_probed \
../dstar_1.4_probed \
../dstar_1.6_probed \
../dstar_1.8_probed \
"
study_cases=" \
../dstar_0.0_probed \
../dstar_0.1_probed \
../dstar_0.2_probed \
../noWallRefine_dstar_0.4_probed \
../noWallRefine_dstar_0.42_probed \
../dstar_0.6_probed \
../dstar_0.8_probed \
../dstar_1.0_probed \
../dstar_1.2_probed \
../noWallRefine_dstar_1.30_probed \
../dstar_1.4_probed \
../dstar_1.6_probed \
../dstar_1.8_probed \
"

usage="((\$1)*1e6):((\$2)/1e6) w l lw 3"
cp $plotfile.backup $plotfile

for num in 1 2
do
    study_cases=""
    cp $plotfile.backup $plotfile
    if [[ $num == 1 ]]
    then
        sed -i "s/YRANGE/10000/g" $plotfile
        study_cases=$study_cases1
        echo "set label \"10000\" at 98,7000" >> $plotfile
    else
        sed -i "s/YRANGE/1000/g" $plotfile
        study_cases=$study_cases2
    fi

    for i in $study_cases
    do
        echo "$i"
        title=$(get_dstar $i)
        dir_to_pressure_file=$(ls $i/probes/*/p_rgh)
        if [[ $(python check_broken_probes_file.py $dir_to_pressure_file) == "broken" ]]
        then
            echo "$i is broken"
        else
            append_to_gnuplot_script $dir_to_pressure_file "$usage" $title
        fi
    done
    echo "unset multiplot" >> $plotfile
    gnuplot $plotfile
    mv pressure_sb.eps pressure_sb_$num.eps
    epstopdf pressure_sb_$num.eps
    rm pressure_sb_$num.eps
    pdfcrop pressure_sb_$num.pdf pressure_sb_$num.pdf
done

study_cases="$study_cases1 $study_cases2"
    outfile="stresses.dat"
    echo "#dstar    avg stress (MPa)    max stress (MPa)" > $outfile
    for i in $study_cases
    do
        echo $i
        cp get_stress_from_probe.py $i
        cd $i
        avg=$(python get_stress_from_probe.py)
        max=$(python get_stress_from_probe.py --type max)
        dstar=$(get_dstar $i)
        cd $thisdir
        echo "$dstar   $avg    $max"  >> $outfile
    done

    plotfile2=plot_stresses_dstar.gnuplot
    cp $plotfile2.backup $plotfile2
    gnuplot $plotfile2
    epstopdf stresses_sb.eps
    epstopdf stresses_sb_log.eps
    rm stresses_sb*.eps
    pdfcrop stresses_sb.pdf stresses_sb.pdf
    pdfcrop stresses_sb_log.pdf stresses_sb_log.pdf





















# re_dos=""
# if [ $do_pressures == "y" ]
# then
#     for i in $study_cases
#     do
#         echo "$i"
#         cd $i
#         cp $thisdir/system/probesDict system/
#         offset=1e-7
#         y_sb=$(python <<< "print($(get_y_sb)+$offset)")
#         sed -i "s/1e-6 1e-6 0.0/$offset $y_sb  0.0/g" system/probesDict
# #         echo "$i   $y_sb" #  
#         mpirun -np 16 probeLocations -parallel > log.probeLocations 2>&1
#         cd $thisdir
#         if [[ $(python check_broken_probes_file.py $i/probes/0/p_rgh) == "broken" ]]
#         then
#             echo "putting $i to re-dos for later with delta x = 1e-6"
#             re_dos="$re_dos $i"
#         fi
#         title=$(get_dstar $i)
#         append_to_gnuplot_script $i "$usage" $title
#     done
#     for i in $re_dos
#     do
#         echo "re-doing: $i"
#         cd $i
#         cp $thisdir/system/probesDict system/
#         offset=1e-6
#         y_sb=$(python <<< "print($(get_y_sb)+$offset)")
#         sed -i "s/1e-6 1e-6 0.0/$offset $y_sb  0.0/g" system/probesDict
# #         echo "$i   $y_sb" #  
#         mpirun -np 16 probeLocations -parallel > log.probeLocations 2>&1
#         cd $thisdir
#         if [[ $(python check_broken_probes_file.py $i/probes/0/p_rgh) == "broken" ]]
#         then
#             echo "$i lost without hope"
#         fi
#     done
# fi
