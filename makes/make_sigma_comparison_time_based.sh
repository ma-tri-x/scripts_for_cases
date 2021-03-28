#!/bin/bash

index_of_radius() {
    radius=$1
    starttime=$2
    endtime=$3
    ti=$(python get_time_of_radius.py -r $1 -t $2 -e $3)
    ts=$(python get_closest_timestep.py -p processor0 -t $ti)
    id=$(python get_index_of_time.py $ts)
    echo $id
}

index_of_time() {
    timestep=$1
    ts=$(python get_closest_timestep.py -p processor0 -t $timestep)
    id=$(python get_index_of_time.py $ts)
    echo $id
}

write_lines_to_gnuplot () {
    i=$1
    id=$2
    ids=$3
    echo "\"${i}/contour/bla0.${id}.csv\" u ( (\$2)*1e6):((\$3)*1e6) w l lc 7 lw 6 notitle,\\" >> plot_sigma_comparison.gnuplot
    echo "\"${i}/contour/bla0.${id}.csv\" u (-(\$2)*1e6):((\$3)*1e6) w l lc 7 lw 6 notitle,\\" >> plot_sigma_comparison.gnuplot
    echo "\"${i}_sigma/contour/bla0.${ids}.csv\" u ( (\$2)*1e6):((\$3)*1e6) w l lc 2 lw 3 notitle,\\" >> plot_sigma_comparison.gnuplot
    echo "\"${i}_sigma/contour/bla0.${ids}.csv\" u (-(\$2)*1e6):((\$3)*1e6) w l lc 2 lw 3 notitle,\\" >> plot_sigma_comparison.gnuplot
}

end_gnuplot_file () {
    echo "\"temp/sigma_piston.dat\" u 1:2 w l lw 2 lc rgbcolor \"black\" notitle" >> plot_sigma_comparison.gnuplot
}

run_gnuplot () {
#     echo "" >> plot_sigma_comparison.gnuplot
#     echo "pause -1 \"press button\"" >> plot_sigma_comparison.gnuplot
    output=$1
    suffix=$2
    gnuplot plot_sigma_comparison.gnuplot
    epstopdf sigma_comparison.eps
    mv sigma_comparison.pdf ${output%.pdf}${suffix}.pdf
    pdfcrop ${output%.pdf}${suffix}.pdf ${output%.pdf}${suffix}.pdf
}

comment_contour_files_first_line () {
    for csvfile in contour/bla*csv;do
        sed -i "s/^\"arc/#\"arc/g"  $csvfile
    done
}

write_times_to_tex_files () {
    timesexp=$(echo "$1" | sed "s/e-6/, /g")
    timesexp=${timesexp%, }"\\mus"
    timescoll=$(echo "$2" | sed "s/e-6/, /g")
    timescoll=${timescoll%, }"\\mus"
    Rn=$3
    echo "\$t=${timesexp}\$\\timegap\$t=${timescoll}\$" > temp/times_Rn${Rn}.tex
}

thisdir=$(pwd)

study_cases=" \
../kk010_piston_axi_static_Rn184.1mum_dinit250mum \
../kk010_piston_axi_static_Rn201.5mum_dinit250mum \
../kk010_piston_axi_static_Rn240.0mum_dinit250mum \
"

echo "produce contours again? [y/n] : "
read bla

if [ "$bla" = "y" ];then
    for i in $study_cases;do
        cd $i
        rm -rf contour/bla*csv
        python render_2D_contours.py
        python merge_split_files.py
        comment_contour_files_first_line
        cd ${i}_sigma
        rm -rf contour/bla*csv
        python render_2D_contours.py
        python merge_split_files.py
        comment_contour_files_first_line
        cd $thisdir
    done
fi

k=1
for i in $study_cases;do
    echo $i
    cd $thisdir
    cp plot_sigma_comparison.gnuplot.backup plot_sigma_comparison.gnuplot
    
    timesexp=""
    timescoll=""
    output=""
    if [ $k == 1 ];then timesexp="1e-6 4.5e-6 25e-6"  ;output="sigma_comparison_Rn184.pdf";fi
    if [ $k == 2 ];then timesexp="1e-6 4.5e-6 20e-6"  ;output="sigma_comparison_Rn201.pdf";fi
    if [ $k == 3 ];then timesexp="0.5e-6 3e-6 14.5e-6";output="sigma_comparison_Rn240.pdf";fi
    if [ $k == 1 ];then timescoll="65e-6 82e-6 88e-6 90e-6";      Rn=184;fi
    if [ $k == 2 ];then timescoll="88e-6 96.2e-6 98.8e-6 99.5e-6";Rn=201;fi
    if [ $k == 3 ];then timescoll="105e-6 115e-6 118e-6 120.2e-6";Rn=240;fi
    
    #expansion
    for j in $timesexp;do
        cd $i
        id=$(index_of_time $j)
        cd ${i}_sigma
        ids=$(index_of_time $j)
        cd $thisdir
        write_lines_to_gnuplot $i $id $ids
    done
    
    cd $thisdir
    end_gnuplot_file
    run_gnuplot $output "expansion"
    
    #collapse
    cp plot_sigma_comparison.gnuplot.backup plot_sigma_comparison.gnuplot
    for j in $timescoll;do
        cd $i
        id=$(index_of_time $j)
        cd ${i}_sigma
        ids=$(index_of_time $j)
        cd $thisdir
        write_lines_to_gnuplot $i $id $ids
    done
    let 'k=k+1'
    cd $thisdir
    end_gnuplot_file
    run_gnuplot $output "collapse"
    
    #Abschluss
    write_times_to_tex_files "$timesexp" "$timescoll" $Rn
done
