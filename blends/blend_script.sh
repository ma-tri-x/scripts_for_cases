#!/bin/bash

thisdir=$(pwd)

numdir=$thisdir
expdir=~/POSTDOC/EXP/2024-01-17_large_gamma_exactP/2024-01-17_large_gamma_Photron/dinit_1_p616/004_dinit_1_p0.616V_C1S0002

get_x_dim_img(){
    theimg=$1
    img_string=$(identify $theimg)
    dims_string=$(python <<< "print(\"${img_string}\".split(\" \")[2])")
    x_dim_string=$(python <<< "print(\"${dims_string}\".split(\"x\")[0])" )
    echo $x_dim_string
}

get_dims_img(){
    theimg=$1
    img_string=$(identify $theimg)
    dims_string=$(python <<< "print(\"${img_string}\".split(\" \")[2])")
    echo $dims_string
}

make_folder_and_convert_there() {
    number=$1
    number=$(python <<< "print(str(${number}).zfill(3))")
    exp_img=004_dinit_1_p0.616V_C1S0002${number}.png
    num_img=$2
    scale_exp=$3
    action_dir=temp #$4 #blend_num_fr$number
    result_dir=anim_blended
    echo "blending $exp_img with $num_img"
    mkdir -p $action_dir
    mkdir -p $result_dir
    cd $action_dir
        cp $numdir/anim/$num_img .
        cp $expdir/$exp_img .
        #
        ## scale so that fiber has same distance
        convert $exp_img -scale $scale_exp +repage scaled_$exp_img
        #
        ## identify scaled_$exp_img says: ???
        ## extract the view that corresponds to experiments:
        #convert scaled_$exp_img -crop 504x768+613+620 +repage scaled_$exp_img # +repage destroys remaining virtual canvas
        #
        ## make white as transparent
        convert $num_img -transparent white 01_$num_img
        #
        ## extract the transparency mask as black=transparent,white=non-transparent
        convert 01_$num_img -alpha extract mask.png
        ## make Black=Black and White=Gray, hence not fully non-transparent
        convert mask.png  +level-colors Black,Gray  mask_bg.png
        #
        ## apply that new mask on the scaled image
        convert 01_$num_img mask_bg.png -alpha Off -compose CopyOpacity -composite 02_$num_img
        #
        ## adjust xy offset
        curr_dims=$(get_dims_img 02_$num_img)
        convert 02_$num_img -page ${curr_dims}+17-273 02_$num_img
        #
        ## overlay exp and num
        convert scaled_$exp_img 02_$num_img -layers merge blend_result_fr${number}.png
        #
        ## tadaaa! if there are white borders left, trim them apart:
        #convert blend_result_fr${number}.png -trim blend_result_fr${number}.png
        #convert blend_result_fr${number}.png -crop 443x653+18+479 +repage blend_result_fr${number}.png
        cp blend_result_fr${number}.png ../$result_dir/
    cd $thisdir
    rm -r $action_dir
}

length_num_mm=10.0
px_per_length_num=596
mm_per_px_exp=$(python <<< "print(1./20.36)")
mm_per_px_num=$(python <<< "print(${length_num_mm}/${px_per_length_num})")
scale_factor_exp=$(python <<< "print(1./($mm_per_px_num/$mm_per_px_exp))")
x_dim_exp=$(get_x_dim_img $expdir/004_dinit_1_p0.616V_C1S0002091.png)
correct_x_dim_exp=$(python <<< "print(int($scale_factor_exp * $x_dim_exp))")
echo "scale factor is: $scale_factor_exp, x_dim_exp is $x_dim_exp and corrected: $correct_x_dim_exp"

fps=30000

python3 get_sorted_times_list.py -p ${numdir%/anim}/processor0  # --> writes into sorted_times_list.dat

i=2
# maxExpNum=198
testMax=142

# while [[ $i -lt $maxExpNum ]]
while [[ $i -lt $testMax ]]
do
    thetime=$(python <<< "print((${i}.)/$fps +(-0.041)*1e-3)")
    index=$(python3 get_index_of_time_from_sorted_times_list.py $thetime)
    num_img=bt058_fit_p616_try02_anim02.$(python <<< "print(str($index).zfill(4))").png
    make_folder_and_convert_there $i $num_img $correct_x_dim_exp
#     echo "i = $i"
    i=$(python <<< "print(int($i + 1))")
#     echo "i = $i"
#     exit 0
done


# cp blend_num_fr*/blend_result_fr*.png .
# montage blend_result_fr*.png -tile 4 -geometry +5+5 montage_blend_results_LMC06.png
