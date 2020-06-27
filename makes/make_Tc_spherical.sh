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


study_cases5=" \
../sp_conv_study_3mum \
../sp_conv_study_2mum \
../sp_conv_study_1.35mum \
../sp_conv_study_1mum \
../sp_conv_study_0.6mum \
../sp_conv_study_0.4mum \
../sp_conv_study_0.2mum \
"

study_cases6=" \
../conv_study_3mum_unbound \
../conv_study_2mum_unbound \
../conv_study_1.35mum_unbound \
../conv_study_1mum_unbound \
../conv_study_0.75mum_unbound \
"

study_cases7=" \
../conv_study_3mum_unbound_int3cells \
../conv_study_2mum_unbound_int3cells \
../conv_study_1.35mum_unbound_int3cells \
../conv_study_1mum_unbound_int3cells \
"
# ../conv_study_0.75mum_unbound_int3cells \

echo "" > Tc_spherical.dat
echo "" > Tc_unbound.dat
echo "" > Tc_unbound_int3cells.dat

make_Tc_dat $study_cases5 -f=Tc_spherical.dat
make_Tc_dat $study_cases6 -f=Tc_unbound.dat
make_Tc_dat $study_cases7 -f=Tc_unbound_int3cells.dat

cp plot_Tc.gnuplot.backup plot_Tc.gnuplot

append_files_to_gnuplot_script Tc_spherical.dat "E=const. + etc. + spherical" ",\\"
append_files_to_gnuplot_script Tc_unbound.dat "E=const. + axisymm + unbound" ",\\"
append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + unbound + 3cells int.f." " "

gnuplot plot_Tc.gnuplot
mv Tc.eps Tc_unbound.eps
epstopdf Tc_unbound.eps
pdfcrop Tc_unbound.pdf Tc_unbound.pdf
rm *.eps
