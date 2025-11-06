#!/bin/bash

thisdir=$(pwd)

numdir=~/zweite_nvme/foamProjects/bt055_lowPatm_compareExp/try03_no_g/anim

get_x_dim_img(){
    theimg=$1
    img_string=$(identify $theimg)
    dims_string=$(python <<< "print(\"${img_string}\".split(\" \")[2])")
    x_dim_string=$(python <<< "print(\"${dims_string}\".split(\"x\")[0])" )
    echo $x_dim_string
}

make_folder_and_convert_there() {
    i=$1  
    base_img=subtracted_Asymm_Faserende_noTimings_fr${i}.png
    num_img=$2
    scale_num=$3
    action_dir=$4 #blend_num_fr$i
    echo "blending $base_img with $num_img"
    mkdir -p $action_dir
    cd $action_dir
        cp $numdir/$num_img .
        cp $thisdir/$base_img .
        #
        ## scale so that fiber has same distance
        convert $num_img -scale $scale_num scaled_$num_img
        #
        ## identify scaled_$num_img says: 1575x1829+0+0
        ## extract the view that corresponds to experiments:
        if [[ $LMC02 == "true" ]]
        then
            convert scaled_$num_img -crop 504x768+611+619 +repage scaled_$num_img # +repage destroys remaining virtual canvas
        else
            convert scaled_$num_img -crop 504x768+613+620 +repage scaled_$num_img # +repage destroys remaining virtual canvas
        fi
        #
        ## make white as transparent
        convert scaled_$num_img -transparent white 01_$num_img
        #
        ## extract the transparency mask as black=transparent,white=non-transparent
        convert 01_$num_img -alpha extract mask.png
        ## make Black=Black and White=Gray, hence not fully non-transparent
        convert mask.png  +level-colors Black,Gray  mask_bg.png
        #
        ## apply that new mask on the scaled image
        convert 01_$num_img mask_bg.png -alpha Off -compose CopyOpacity -composite 02_$num_img
        #
        ## overlay exp and num
        convert $base_img 02_$num_img -layers merge blend_result_fr${i}.png
        #
        ## tadaaa! if there are white borders left, trim them apart:
        convert blend_result_fr${i}.png -trim blend_result_fr${i}.png
    cd $thisdir
}

width_px_fiber_num=101
width_px_fiber_exp=153
scale_factor_num=$(python <<< "print(${width_px_fiber_exp}./$width_px_fiber_num)")
x_dim_num=$(get_x_dim_img $numdir/bt051_LMC06_anim01.0100.png)
correct_x_dim_num=$(python <<< "print(int($scale_factor_num * $x_dim_num))")

i=1
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0069.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=2
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0073.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=3
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0077.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=4
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0081.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=5
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0086.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=6
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0090.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=7
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0102.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=8
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0142.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

i=9
action_dir=blend_num_fr$i
num_img=bt051_LMC06_anim01.0207.png
make_folder_and_convert_there $i $num_img $correct_x_dim_num $action_dir

# i=10
# num_img=bt051_LMC06_anim01.0044.png
# make_folder_and_convert_there $i $num_img $correct_x_dim_num
# 
# i=11
# num_img=bt051_LMC06_anim01.0044.png
# make_folder_and_convert_there $i $num_img $correct_x_dim_num
# 
# i=12
# num_img=bt051_LMC06_anim01.0044.png
# make_folder_and_convert_there $i $num_img $correct_x_dim_num

cp blend_num_fr*/blend_result_fr*.png .
montage blend_result_fr*.png -tile 4 -geometry +5+5 montage_blend_results_LMC06.png
