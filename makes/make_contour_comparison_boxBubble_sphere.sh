#!/bin/bash

thisdir=$(pwd)

#times="97e-6 98e-6 99e-6"
times="1e-10 1e-6 4e-6 6e-6"

echo "PLEASE sort in ascending delta x"
echo "PLEASE put first case twice"

study_cases=" \
../dstar_1.6 \
../dstar_1.6 \
../../kk008_batch_simu_Dstar/dstar_1.6 \
../../kk008_batch_simu_Dstar/dstar_1.6 \
"

plotfile=plot_contour_at_radius_V2.gnuplot

bubble_dinit=$(python getparm.py -s bubble -q D_init)
center="${bubble_dinit}*1e6"
echo "adjust y-origin to $center ? [y/n]"
read answ
if [ ! $answ == "y" ];then center=0;fi

### FUNCS that must know above variables: #####
case_count=0
for i in $study_cases
do
    let 'case_count = case_count + 1'
done

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

get_contour_path () {
    dir=$1
    time_in=$2
    time=$(python $dir/get_closest_timestep.py -p processor0 -t $time_in )
    time_idx=$(python $dir/get_index_of_time.py $time ) 
    file="bla0.${time_idx}.csv"
    echo "$dir/contour/$file"
}

################################################

# echo "NOTE: if somewhere/contour/*.csv are missing"
# echo "      then execute once"
# echo "         python render_2D_contours.py"
# echo "         python merge_split_files.py"
# echo "      in the dir where they are missing"


i=1
for time_in in $times
do
    k=1
    cp ${plotfile}.backup $plotfile
    sed -i "s/center/$center/g" $plotfile
    sed -i "s/set xrange.*/set xrange \[-300:300\]/g" $plotfile
    sed -i "s/set yrange.*/set yrange \[-300:300\]/g" $plotfile
    for j in $study_cases
    do
        data=$(get_contour_path $j $time_in)
        title="$(get_dx $j){/Symbol m}m"
        lw=3
        lc=$k
        suffix=",\\"
        if [[ $k == 1 ]]; then lw=7; lc=7; title="sphere start 1{/Symbol m}m";fi
        if [[ $k == 2 ]]; then lw=7; lc=7; title=""; fi
        if [[ $k == 3 ]]; then lc="rgbcolor \"0x0000FF\" dt 1"; title="box start 2{/Symbol m}m"; fi
        if [[ $k == 4 ]]; then lc="rgbcolor \"0x0000FF\" dt 1"; title="";fi
        #if [[ $k == 4 ]]; then lc="3 dt 1"; fi
        if [[ $k == 5 ]]; then lc="2 dt 2"; lw=5; fi
        if [[ $k == 6 ]]; then lc="8 dt 1"; fi
        if [[ $k == 7 ]]; then lc="9 dt 1"; fi
        if [[ $k == 8 ]]; then lc="10 dt 2"; fi
        if [[ $k == 9 ]]; then lc="11 dt 2"; fi
        opts="lw $lw lc $lc"
        if [ $k == $case_count ];then suffix=" ";fi
        sign=$(echo "scale=0;${k}%2" | bc -l)
        if [ $sign == 1 ];then sign=" ";else sign="-";fi
#         if [ $k == 2 ];then sign="-";fi
        echo "\"${data}\" u (${sign}(\$2)*1e6):((\$3)*1e6) w l $opts t \"${title}\"${suffix}" >> $plotfile
        let 'k=k+1'
    done
    gnuplot $plotfile
    cp contour.png contour_${time_in}_sec.png
    let 'i=i+1'
done

for time_in in $times;do
    convert contour.png contour_${time_in}_sec.png -background white -gravity center -compose dstover -composite contour.png
done

convert contour.png -background white -flatten contour_dstar1.6.jpg
rm contour*.png

