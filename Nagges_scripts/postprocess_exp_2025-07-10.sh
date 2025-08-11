#!/bin/bash

thisdir=$(pwd)
srcdir=Stop

get_number(){
    arg=$1
    num=$(python <<< "print(\"${arg}\".split(\"_\")[0])")
    echo $num
}


# cropped_stop
# start
# start_2
# start_3
# Stop
# stop_2
# Stop_auf_0
thedirs="
crop_stop_2
"

# for thedir in $thedirs
# do
#     cd $thedir
#     ffmpeg -i $thedir.avi -pattern_type sequence $thedir.%04d.png
#     cd $thisdir
# done



# for thedir in $thedirs
# do
#     echo $thedir
#     # subtract_background
#     stage_one_prefix=bcksbtr
#     stage_one_dir=$thedir/$stage_one_prefix
#         
#     mkdir -p $stage_one_dir
#     cp $thedir/*.cihx $stage_one_dir
#     background_file=$thedir/${thedir}.0001.png
#     #background_file=created_background/created_background.png
#     for i in $thedir/*png
#     do
#         echo $i
#         python3 pp_2_background_subtraction_of_one_img_V1.1.py -i $i -b $background_file -o $stage_one_dir/${stage_one_prefix}_$(basename $i)
#     done
# done

for thedir in $thedirs
do
    echo $thedir
    
    # subtract_background
    #stage_one_prefix=bcksbtr
    #stage_one_dir=$thedir/$stage_one_prefix
    stage_one_dir=$thedir
    mkdir -p $thedir/contours
    rm    -f $thedir/contours/contour_*png
    
    python3 binarize_exp_and_fit_contour_Nagge.py -d "$stage_one_dir" --pxpermm 218.716
    echo "mv area_of_bubble.dat ${thedir}_area_of_bubble.dat"
    mv area_of_bubble.dat ${thedir}_area_of_bubble.dat
    mv fps.dat ${thedir}_fps.dat
    mv $stage_one_dir/contour_*png $thedir/contours
#     exit 0
done

# for thedir in $thedirs
# do
#     bubbledir=$thedir
#     echo $thedir
#     
#     # subtract_background
#     enhanced_dir=enhanced
#     imgs_dir=$thedir
#     dest_dir=$thedir/$enhanced_dir
#     mkdir -p $dest_dir
#     rm -f $dest_dir/enh_*png
#     
#     #echo "python3 pp_3_enhance_contrast_of_png_stack.py \"$imgs_dir/${thedir}*png\""
#     python3 pp_3_enhance_contrast_of_png_stack.py "$imgs_dir/${thedir}*png"
#     mv $imgs_dir/enh_*png $dest_dir
#     #exit 0
# done

