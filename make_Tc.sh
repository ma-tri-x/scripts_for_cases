#!/bin/bash

thisdir=$(pwd)

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

make_Tc_dat () {
    study_cases=""
    for i in "$@"
    do
    case $i in
        -f=*|--file=*)
        Tc_file="${i#*=}"
        shift # past argument=value
        ;;
        *conv_study*)
        study_cases="$study_cases $i"    # unknown option
        ;;
    esac
    done
    for i in $study_cases;do
        cp $thisdir/get_Tc.py $i/
        cd $i
        dx=$(get_dx $i )
        Tc=$(python get_Tc.py)
        echo "${dx}e-6    $Tc " >> $thisdir/$Tc_file
        cd $thisdir
    done
}

append_files_to_gnuplot_script () {
    data=$1
    title=$2
    suffix=$3
    if [ $# == 4 ];then
        opts=$4
        echo "\"${data}\"   u ((\$1)*1e6):((\$2)*1e6) w lp $opts t \"${title}\"${suffix}" >> plot_Tc.gnuplot 
    else
        echo "\"${data}\"   u ((\$1)*1e6):((\$2)*1e6) w lp t \"${title}\"${suffix}" >> plot_Tc.gnuplot 
    fi
}

study_cases1=" \
../conv_study_3mum_Econst \
../conv_study_2mum_Econst \
../conv_study_1.35mum_Econst \
../conv_study_1.2mum_Econst \
../conv_study_1mum_Econst \
../conv_study_0.65mum_Econst_wp14 \
../conv_study_0.5mum_Econst_wp14 \
"

study_cases2=" \
../conv_study_3mum_Econst_RnChange \
../conv_study_2mum_Econst_RnChange \
../conv_study_1.35mum_Econst_RnChange \
../conv_study_1.2mum_Econst_RnChange \
../conv_study_1mum_Econst_RnChange \
../conv_study_0.75mum_Econst_RnChange \
"

study_cases3=" \
../conv_study_3mum_Econst_RnChange_maxCo0.1 \
../conv_study_2mum_Econst_RnChange_maxCo0.1 \
../conv_study_1.35mum_Econst_RnChange_maxCo0.1 \
../conv_study_1.2mum_Econst_RnChange_maxCo0.1 \
../conv_study_1mum_Econst_RnChange_maxCo0.1 \
"

study_cases4=" \
../conv_study_3mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_2mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_1.35mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_1mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus \
../conv_study_0.6mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus_fromBerlin_naked \
"

# study_cases5=" \
# ../sp_conv_study_3mum \
# ../sp_conv_study_2mum \
# ../sp_conv_study_1.35mum \
# ../sp_conv_study_1mum \
# ../sp_conv_study_0.6mum \
# ../sp_conv_study_0.4mum \
# ../sp_conv_study_0.2mum \
# "

study_cases6=" \
../conv_study_3mum_refine \
../conv_study_2mum_refine \
../conv_study_1.35mum_refine \
../conv_study_1mum_refine \
../conv_study_0.75mum_refine \
../conv_study_0.6mum_refine \
"

study_cases7=" \
../conv_study_0.75mum_refine_low_res \
../conv_study_1mum_refine_low_res \
../conv_study_1.35mum_refine_low_res \
../conv_study_2mum_refine_low_res \
"

echo "" > Tc_RnChange.dat
echo "" > Tc_Econst.dat
echo "" > Tc_maxCo01.dat
echo "" > Tc_tRn60mus.dat
echo "" > Tc_refine.dat
echo "" > Tc_refine_low_res.dat

make_Tc_dat $study_cases1 -f=Tc_Econst.dat
make_Tc_dat $study_cases2 -f=Tc_RnChange.dat
make_Tc_dat $study_cases3 -f=Tc_maxCo01.dat
make_Tc_dat $study_cases4 -f=Tc_tRn60mus.dat
make_Tc_dat $study_cases5 -f=Tc_spherical.dat
make_Tc_dat $study_cases6 -f=Tc_refine.dat
make_Tc_dat $study_cases7 -f=Tc_refine_low_res.dat

cp plot_Tc.gnuplot.backup plot_Tc.gnuplot

append_files_to_gnuplot_script Tc_Econst.dat   "case a0)" ",\\" "lw 3" #"E=const. " ",\\"  
append_files_to_gnuplot_script Tc_RnChange.dat "case a)" ",\\" "lw 4 dt 2" #"E=const. + adapt R_n" ",\\" 
append_files_to_gnuplot_script Tc_maxCo01.dat  "case b)" ",\\" #"E=const. + adapt R_n + maxCo=0.1" ",\\" 
append_files_to_gnuplot_script Tc_tRn60mus.dat "case c)" ",\\" #"E=const. + adapt R_n + maxCo=0.2 + maxAlphaCo0.08 +tRn60-75" ",\\"
append_files_to_gnuplot_script Tc_refine.dat   "case d)" ",\\" "lc 7" #"E=const. etc + refined mesh" ",\\" 7
append_files_to_gnuplot_script Tc_refine_low_res.dat "case e)" ",\\" "lc 8" #"refined, low res. mesh" " " 8

# append_files_to_gnuplot_script Tc_spherical.dat "E=const. + etc. + spherical" " "

gnuplot plot_Tc.gnuplot
epstopdf Tc.eps
pdfcrop Tc.pdf Tc.pdf
rm *.eps
