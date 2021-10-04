#!/bin/bash

thisdir=$(pwd)
look_for_file=processor0/bubble_y_distance_min.dat

casedirs="Rn227.25_dinit30
Rn227.25_dinit90
Rn227.25_dinit150
Rn227.25_dinit250
Rn227.25_dinit350
Rn227.25_dinit400
Rn227.25_dinit450
"

#for thecase in $casedirs
for thecase in Rn105.20* Rn116.48* Rn131.52* Rn152.58*
do
    if [ -d $thecase ]
    then
        cd $thecase
        if [ ! -e $look_for_file ]
        then
            echo $thecase
            mpirun -np 32 get_bubble_y_distance -parallel > log.get_bubble_y_distance 2>&1
            tail log.get_bubble_y_distance
        fi
        cd $thisdir
    fi
done
