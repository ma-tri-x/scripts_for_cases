#!/bin/bash

thisdir=$(pwd)

plotfile=plot_Tc_spherical.gnuplot

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
        echo "\"${data}\"   u ((\$1)*1e6):((\$2)*1e6) w lp $opts t \"${title}\"${suffix}" >> $plotfile
    else
        echo "\"${data}\"   u ((\$1)*1e6):((\$2)*1e6) w lp t \"${title}\"${suffix}" >> $plotfile
    fi
}


study_cases1=" \
../sp_conv_study_3mum \
../sp_conv_study_2mum \
../sp_conv_study_1.35mum \
../sp_conv_study_1mum \
../sp_conv_study_0.6mum \
../sp_conv_study_0.4mum \
../sp_conv_study_0.2mum \
../sp_conv_study_0.1mum \
../sp_conv_study_0.05mum \
../sp_conv_study_0.02mum \
"

study_cases2=" \
../conv_study_3mum_unbound \
../conv_study_2mum_unbound \
../conv_study_1.35mum_unbound \
../conv_study_1mum_unbound \
../conv_study_0.75mum_unbound \
"

study_cases3=" \
../conv_study_3mum_unbound_int3cells \
../conv_study_2mum_unbound_int3cells \
../conv_study_1.35mum_unbound_int3cells \
../conv_study_1mum_unbound_int3cells \
"

study_cases4=" \
../sp_conv_study_3mum_int3cells \
../sp_conv_study_2mum_int3cells \
../sp_conv_study_1.35mum_int3cells \
../sp_conv_study_1mum_int3cells \
../sp_conv_study_0.6mum_int3cells \
../sp_conv_study_0.4mum_int3cells \
../sp_conv_study_0.2mum_int3cells \
../sp_conv_study_0.1mum_int3cells \
../sp_conv_study_0.05mum_int3cells \
../sp_conv_study_0.02mum_int3cells \
../sp_conv_study_0.015mum_int3cells \
"

study_cases5=" \
../sp_conv_study_3mum_GMC_int3cells \
../sp_conv_study_2mum_GMC_int3cells \
../sp_conv_study_1.35mum_GMC_int3cells \
../sp_conv_study_1mum_GMC_int3cells \
../sp_conv_study_0.6mum_GMC_int3cells \
../sp_conv_study_0.4mum_GMC_int3cells \
../sp_conv_study_0.2mum_GMC_int3cells \
../sp_conv_study_0.1mum_GMC_int3cells \
../sp_conv_study_0.09mum_GMC_int3cells \
../sp_conv_study_0.07mum_GMC_int3cells \
"

study_cases6=" \
../sp_conv_study_3mum_GMC_int3cells_sigma0 \
../sp_conv_study_2mum_GMC_int3cells_sigma0 \
../sp_conv_study_1.35mum_GMC_int3cells_sigma0 \
../sp_conv_study_1mum_GMC_int3cells_sigma0 \
../sp_conv_study_0.6mum_GMC_int3cells_sigma0 \
../sp_conv_study_0.4mum_GMC_int3cells_sigma0 \
../sp_conv_study_0.2mum_GMC_int3cells_sigma0 \
../sp_conv_study_0.1mum_GMC_int3cells_sigma0 \
../sp_conv_study_0.09mum_GMC_int3cells_sigma0 \
../sp_conv_study_0.07mum_GMC_int3cells_sigma0 \
"

study_cases7=" \
../sp_conv_study_3mum_int3cells_XF100 \
../sp_conv_study_2mum_int3cells_XF100 \
../sp_conv_study_1.35mum_int3cells_XF100 \
../sp_conv_study_1mum_int3cells_XF100 \
../sp_conv_study_0.6mum_int3cells_XF100 \
../sp_conv_study_0.4mum_int3cells_XF100 \
../sp_conv_study_0.2mum_int3cells_XF100 \
../sp_conv_study_0.1mum_int3cells_XF100 \
../sp_conv_study_0.09mum_int3cells_XF100 \
../sp_conv_study_0.07mum_int3cells_XF100 \
"

study_cases8=" \
../sp_conv_study_3mum_int3cells_CLmesh \
../sp_conv_study_2mum_int3cells_CLmesh \
../sp_conv_study_1.35mum_int3cells_CLmesh \
../sp_conv_study_1mum_int3cells_CLmesh \
../sp_conv_study_0.6mum_int3cells_CLmesh \
../sp_conv_study_0.4mum_int3cells_CLmesh \
../sp_conv_study_0.2mum_int3cells_CLmesh \
../sp_conv_study_0.1mum_int3cells_CLmesh \
../sp_conv_study_0.09mum_int3cells_CLmesh \
../sp_conv_study_0.07mum_int3cells_CLmesh \
"

study_cases9=" \
../sp_conv_study_3mum_CLmesh \
../sp_conv_study_2mum_CLmesh \
../sp_conv_study_1.35mum_CLmesh \
../sp_conv_study_1mum_CLmesh \
../sp_conv_study_0.6mum_CLmesh \
../sp_conv_study_0.4mum_CLmesh \
../sp_conv_study_0.2mum_CLmesh \
../sp_conv_study_0.1mum_CLmesh \
../sp_conv_study_0.09mum_CLmesh \
../sp_conv_study_0.07mum_CLmesh \
"

study_cases10=" \
../sp_conv_study_3mum_XF100 \
../sp_conv_study_2mum_XF100 \
../sp_conv_study_1.35mum_XF100 \
../sp_conv_study_1mum_XF100 \
../sp_conv_study_0.6mum_XF100 \
../sp_conv_study_0.4mum_XF100 \
../sp_conv_study_0.2mum_XF100 \
../sp_conv_study_0.1mum_XF100 \
../sp_conv_study_0.09mum_XF100 \
"

# study_cases4=" \
# ../sp_conv_study_0.1mum \
# "

# ../conv_study_0.75mum_unbound_int3cells \

echo "" > Tc_spherical.dat
echo "" > Tc_unbound.dat
echo "" > Tc_unbound_int3cells.dat
# echo "" > Tc_spherical_int3cells.dat
echo "" > Tc_spherical_GMC_int3cells.dat
echo "" > Tc_spherical_GMC_int3cells_sigma0.dat
echo "" > Tc_spherical_int3cells_XF100.dat
echo "" > Tc_spherical_int3cells_CLmesh.dat
echo "" > Tc_spherical_CLmesh.dat
echo "" > Tc_spherical_XF100.dat

make_Tc_dat $study_cases1  -f=Tc_spherical.dat
make_Tc_dat $study_cases2  -f=Tc_unbound.dat
make_Tc_dat $study_cases3  -f=Tc_unbound_int3cells.dat
# make_Tc_dat $study_cases4  -f=Tc_spherical_int3cells.dat
make_Tc_dat $study_cases5  -f=Tc_spherical_GMC_int3cells.dat
make_Tc_dat $study_cases6  -f=Tc_spherical_GMC_int3cells_sigma0.dat
make_Tc_dat $study_cases7  -f=Tc_spherical_int3cells_XF100.dat
make_Tc_dat $study_cases8  -f=Tc_spherical_int3cells_CLmesh.dat
make_Tc_dat $study_cases9  -f=Tc_spherical_CLmesh.dat
make_Tc_dat $study_cases10 -f=Tc_spherical_XF100.dat

cp $plotfile.backup $plotfile
# sed -i "s/SETTINGS/set xrange \[0.1:\*\]\nset yrange \[\*:\*\]\nset logscale x\nset xtics out (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3) rotate by -45/g" $plotfile
sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]\nset logscale x/g" $plotfile
# sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]/g" $plotfile

append_files_to_gnuplot_script Tc_spherical.dat "spherical + sharp int.f." ",\\"
append_files_to_gnuplot_script Tc_unbound.dat "axisymm + sharp int.f." ",\\"
append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_int3cells.dat "spherical + 3 cells int.f." " "
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells.dat "spherical + GMC + 3cells int.f." ",\\" "lc 6"
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells_sigma0.dat "spherical + GMC + 3cells int.f. + sigma=0" ",\\" "lc 7"
#append_files_to_gnuplot_script Tc_spherical_int3cells_XF100.dat "spherical + 3cells int.f. + BC moved to 100Rmax" ",\\" "lc 8"
#append_files_to_gnuplot_script Tc_spherical_int3cells_CLmesh.dat "spherical + 3cells int.f. + mesh CL" ",\\" "lc 10"
#append_files_to_gnuplot_script ~/Desktop/2000PhD-thesis/Notes_CL/CL_conv.dat "data CL" " " "lc 11"


gnuplot $plotfile
mv Tc.eps Tc_spherical_and_unbound_logscale.eps
epstopdf Tc_spherical_and_unbound_logscale.eps
pdfcrop Tc_spherical_and_unbound_logscale.pdf Tc_spherical_and_unbound_logscale.pdf
rm *.eps









cp $plotfile.backup $plotfile
# sed -i "s/SETTINGS/set xrange \[0.1:\*\]\nset yrange \[\*:\*\]\nset logscale x\nset xtics out (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3) rotate by -45/g" $plotfile
#sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]\nset logscale x/g" $plotfile
sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]/g" $plotfile

append_files_to_gnuplot_script Tc_spherical.dat "spherical + sharp int.f." ",\\"
append_files_to_gnuplot_script Tc_unbound.dat "axisymm + sharp int.f." ",\\"
append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_int3cells.dat "spherical + 3 cells int.f." " "
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells.dat "spherical + GMC + 3cells int.f." ",\\" "lc 6"
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells_sigma0.dat "spherical + GMC + 3cells int.f. + sigma=0" ",\\" "lc 7"
#append_files_to_gnuplot_script Tc_spherical_int3cells_XF100.dat "spherical + 3cells int.f. + BC moved to 100Rmax" ",\\" "lc 8"
#append_files_to_gnuplot_script Tc_spherical_int3cells_CLmesh.dat "spherical + 3cells int.f. + mesh CL" ",\\" "lc 10"
#append_files_to_gnuplot_script ~/Desktop/2000PhD-thesis/Notes_CL/CL_conv.dat "data CL" " " "lc 11"


gnuplot $plotfile
mv Tc.eps Tc_spherical_and_unbound.eps
epstopdf Tc_spherical_and_unbound.eps
pdfcrop Tc_spherical_and_unbound.pdf Tc_spherical_and_unbound.pdf
rm *.eps







cp $plotfile.backup $plotfile
# sed -i "s/SETTINGS/set xrange \[0.1:\*\]\nset yrange \[\*:\*\]\nset logscale x\nset xtics out (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3) rotate by -45/g" $plotfile
#sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]\nset logscale x/g" $plotfile
sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]/g" $plotfile

append_files_to_gnuplot_script Tc_spherical.dat "spherical + sharp int.f." ",\\"
append_files_to_gnuplot_script Tc_unbound.dat "axisymm + sharp int.f." ",\\"
#append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_int3cells.dat "spherical + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_GMC_int3cells.dat "spherical + GMC + 3 cells int.f." ",\\" "lc 6"
append_files_to_gnuplot_script Tc_spherical_GMC_int3cells_sigma0.dat "spherical + GMC + 3 cells int.f. + sigma=0" " " "lc 7"
#append_files_to_gnuplot_script Tc_spherical_int3cells_XF100.dat "spherical + 3cells int.f. + BC moved to 100Rmax" ",\\" "lc 8"
#append_files_to_gnuplot_script Tc_spherical_int3cells_CLmesh.dat "spherical + 3cells int.f. + mesh CL" ",\\" "lc 10"
#append_files_to_gnuplot_script ~/Desktop/2000PhD-thesis/Notes_CL/CL_conv.dat "data CL" " " "lc 11"


gnuplot $plotfile
mv Tc.eps Tc_spherical_and_unbound_GMC.eps
epstopdf Tc_spherical_and_unbound_GMC.eps
pdfcrop Tc_spherical_and_unbound_GMC.pdf Tc_spherical_and_unbound_GMC.pdf
rm *.eps






cp $plotfile.backup $plotfile
# sed -i "s/SETTINGS/set xrange \[0.1:\*\]\nset yrange \[\*:\*\]\nset logscale x\nset xtics out (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3) rotate by -45/g" $plotfile
sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]\nset logscale x/g" $plotfile
#sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]/g" $plotfile

append_files_to_gnuplot_script Tc_spherical.dat "spherical + sharp int.f." ",\\"
append_files_to_gnuplot_script Tc_unbound.dat "axisymm + sharp int.f." ",\\"
#append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_int3cells.dat "spherical + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_GMC_int3cells.dat "spherical + GMC + 3 cells int.f." ",\\" "lc 6"
append_files_to_gnuplot_script Tc_spherical_GMC_int3cells_sigma0.dat "spherical + GMC + 3 cells int.f. + sigma=0" " " "lc 7"
#append_files_to_gnuplot_script Tc_spherical_int3cells_XF100.dat "spherical + 3cells int.f. + BC moved to 100Rmax" ",\\" "lc 8"
#append_files_to_gnuplot_script Tc_spherical_int3cells_CLmesh.dat "spherical + 3cells int.f. + mesh CL" ",\\" "lc 10"
#append_files_to_gnuplot_script ~/Desktop/2000PhD-thesis/Notes_CL/CL_conv.dat "data CL" " " "lc 11"


gnuplot $plotfile
mv Tc.eps Tc_spherical_and_unbound_GMC_logscale.eps
epstopdf Tc_spherical_and_unbound_GMC_logscale.eps
pdfcrop Tc_spherical_and_unbound_GMC_logscale.pdf Tc_spherical_and_unbound_GMC_logscale.pdf
rm *.eps







cp $plotfile.backup $plotfile
# sed -i "s/SETTINGS/set xrange \[0.1:\*\]\nset yrange \[\*:\*\]\nset logscale x\nset xtics out (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3) rotate by -45/g" $plotfile
sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]\nset logscale x/g" $plotfile
#sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]/g" $plotfile

append_files_to_gnuplot_script Tc_spherical.dat "spherical + sharp int.f." ",\\"
#append_files_to_gnuplot_script Tc_unbound.dat "axisymm + sharp int.f." ",\\"
#append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_int3cells.dat "spherical + 3 cells int.f." ",\\"
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells.dat "spherical + GMC + 3 cells int.f." ",\\" "lc 6"
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells_sigma0.dat "spherical + GMC + 3 cells int.f. + sigma=0" " " "lc 7"
append_files_to_gnuplot_script Tc_spherical_int3cells_XF100.dat "spherical + 3cells int.f. + BC moved to 100Rmax" ",\\"
#append_files_to_gnuplot_script Tc_spherical_int3cells_CLmesh.dat "spherical + 3 cells int.f. + mesh 2" ",\\" "lc 10"
#append_files_to_gnuplot_script ~/Desktop/2000PhD-thesis/Notes_CL/CL_conv.dat "data CL" ",\\" "lc 11"
append_files_to_gnuplot_script Tc_spherical_CLmesh.dat "spherical + mesh 2" ",\\"
append_files_to_gnuplot_script Tc_spherical_XF100.dat "spherical + + BC moved to 100Rmax" " " "lc 7"


gnuplot $plotfile
mv Tc.eps Tc_spherical_and_unbound_XF100_logscale.eps
epstopdf Tc_spherical_and_unbound_XF100_logscale.eps
pdfcrop Tc_spherical_and_unbound_XF100_logscale.pdf Tc_spherical_and_unbound_XF100_logscale.pdf
rm *.eps







cp $plotfile.backup $plotfile
# sed -i "s/SETTINGS/set xrange \[0.1:\*\]\nset yrange \[\*:\*\]\nset logscale x\nset xtics out (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3) rotate by -45/g" $plotfile
#sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]\nset logscale x/g" $plotfile
sed -i "s/SETTINGS/set xrange \[0.005:\*\]\nset yrange \[\*:\*\]/g" $plotfile

append_files_to_gnuplot_script Tc_spherical.dat "spherical + sharp int.f." ",\\"
#append_files_to_gnuplot_script Tc_unbound.dat "axisymm + sharp int.f." ",\\"
#append_files_to_gnuplot_script Tc_unbound_int3cells.dat "axisymm + 3 cells int.f." ",\\"
append_files_to_gnuplot_script Tc_spherical_int3cells.dat "spherical + 3 cells int.f." ",\\"
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells.dat "spherical + GMC + 3 cells int.f." ",\\" "lc 6"
#append_files_to_gnuplot_script Tc_spherical_GMC_int3cells_sigma0.dat "spherical + GMC + 3 cells int.f. + sigma=0" " " "lc 7"
append_files_to_gnuplot_script Tc_spherical_int3cells_XF100.dat "spherical + 3cells int.f. + BC moved to 100Rmax" ",\\"
#append_files_to_gnuplot_script Tc_spherical_int3cells_CLmesh.dat "spherical + 3 cells int.f. + mesh 2" ",\\" "lc 10"
#append_files_to_gnuplot_script ~/Desktop/2000PhD-thesis/Notes_CL/CL_conv.dat "data CL" ",\\" "lc 11"
append_files_to_gnuplot_script Tc_spherical_CLmesh.dat "spherical + mesh 2" ",\\"
append_files_to_gnuplot_script Tc_spherical_XF100.dat "spherical + + BC moved to 100Rmax" " " "lc 7"




gnuplot $plotfile
mv Tc.eps Tc_spherical_and_unbound_XF100.eps
epstopdf Tc_spherical_and_unbound_XF100.eps
pdfcrop Tc_spherical_and_unbound_XF100.pdf Tc_spherical_and_unbound_XF100.pdf
rm *.eps
