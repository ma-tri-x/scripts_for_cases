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
    echo "\"${data}\"   u ((\$1)*1e6):((\$2)*1e6) w lp t \"${title}\"${suffix}" >> plot_Tc.gnuplot 
}

study_cases=" \
../conv_study_3mum_Econst_RnChange \
../conv_study_2mum_Econst_RnChange \
../conv_study_1.35mum_Econst_RnChange \
../conv_study_1.2mum_Econst_RnChange \
../conv_study_1mum_Econst_RnChange \
../conv_study_0.75mum_Econst_RnChange \
"


study_cases2=" \
../conv_study_3mum_Econst \
../conv_study_2mum_Econst \
../conv_study_1.35mum_Econst \
../conv_study_1.2mum_Econst \
../conv_study_1mum_Econst \
../conv_study_0.65mum_Econst_wp14 \
../conv_study_0.5mum_Econst_wp14 \
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
"

echo "" > Tc_RnChange.dat
echo "" > Tc_Econst.dat
echo "" > Tc_maxCo01.dat
echo "" > Tc_tRn60mus.dat

make_Tc_dat $study_cases  -f=Tc_RnChange.dat
make_Tc_dat $study_cases2 -f=Tc_Econst.dat
make_Tc_dat $study_cases3 -f=Tc_maxCo01.dat
make_Tc_dat $study_cases4 -f=Tc_tRn60mus.dat

cp plot_Tc.gnuplot.backup plot_Tc.gnuplot

append_files_to_gnuplot_script Tc_RnChange.dat "E=const." ",\\" 
append_files_to_gnuplot_script Tc_Econst.dat   "E=const. + adapt R_n" ",\\"  
append_files_to_gnuplot_script Tc_maxCo01.dat  "E=const. + adapt R_n + maxCo=0.1" ",\\" 
append_files_to_gnuplot_script Tc_tRn60mus.dat "E=const. + adapt R_n + maxCo=0.2 + maxAlphaCo0.08 +tRn60-75" " "

gnuplot plot_Tc.gnuplot
epstopdf Tc.eps
pdfcrop Tc.pdf Tc.pdf
rm *.eps
