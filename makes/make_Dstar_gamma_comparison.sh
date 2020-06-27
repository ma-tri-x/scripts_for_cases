#!/bin/bash

thisdir=$(pwd)

get_dstar ()
{
    echo "$(python <<< "print(\"${1}\".split(\"_\")[-1])")"
}

echo "Linear fit or non-linear? [l/n]"
read linear

echo "re-make Rmax_ydist_of_dstar.dat? [y/n]"
read remake


study_cases=" \
../dstar_0.2 \
../noWallRefine_dstar_0.4 \
../noWallRefine_dstar_0.42 \
../dstar_0.6 \
../dstar_0.8 \
../dstar_1.0 \
../dstar_1.2 \
../dstar_1.4 \
../dstar_1.6 \
../dstar_1.8 \
"
echo "#dstar    Rmax  ydist"
echo "#dstar    Rmax  ydist" > Rmax_ydist_of_dstar.dat
if [ $remake == "y" ]
then
    echo "RmaxMethod top-center (c), Volume (v)?"
    read RmaxMethod
    echo "ydistMethod center (c), centerRmax (r), by D* at t=0 (d)?"
    read ydistMethod
    if [ $ydistMethod == "c" ];then echo "at which time?";read thetime;fi
    for i in $study_cases;do
        cp get_time_of_Rmax.py $i/
        cd $i
        dstar=$(get_dstar $i)
        #ydist: 
        if [ ! $ydistMethod == "d" ]
        then
            if [ $ydistMethod == "r" ]
            then
                thetime=$(python get_time_of_Rmax.py) #tRmax
            fi
            writtenTimestep=$(python get_closest_timestep.py -t $thetime -p processor0)
            threads=$(python getparm.py -s decompose -q threads)
            mpirun -np $threads get_bubble_y_distance -time $writtenTimestep -parallel > log.make_Dstar_gamma_comparison
            center=$(cat processor0/bubble_y_distance.dat)
            top=$(cat processor0/bubble_y_distance_max.dat)
            ydist=$center
        else
            ydist=$(python <<< "print($dstar * 495e-6)")
        fi
        
        #Rmax
        Rmax=$(python get_Rmax_by_THETA.py)
        if [ $RmaxMethod == "c" ]
        then
            tRmax=$(python get_time_of_Rmax.py)
            writtenTimestep=$(python get_closest_timestep.py -t $tRmax -p processor0)
            threads=$(python getparm.py -s decompose -q threads)
            mpirun -np $threads get_bubble_y_distance -time $writtenTimestep -parallel > log.make_Dstar_gamma_comparison
            center=$(cat processor0/bubble_y_distance.dat)
            top=$(cat processor0/bubble_y_distance_max.dat)
            ydist=$center
            Rmax=$(python <<< "print($top - $center)")
        fi
        echo "$dstar    $Rmax   $ydist"
        echo "$dstar    $Rmax   $ydist" >> $thisdir/Rmax_ydist_of_dstar.dat
        cd $thisdir
    done
fi

    
if [ $linear == "l" ]
then
    gnuplot plot_Dstar_gamma_comparison_linear.gnuplot
else
    gnuplot plot_Dstar_gamma_comparison.gnuplot
fi
epstopdf Dstar_gamma_comparison.eps
pdfcrop Dstar_gamma_comparison.pdf Dstar_gamma_comparison.pdf
rm Dstar_gamma_comparison.eps
