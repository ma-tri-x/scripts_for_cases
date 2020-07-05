#!/bin/bash
pi="3.14159265358979323846264338327950288"

thisdir=$(pwd)

plotfile=plot_jet_speed.gnuplot

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

data_plt_cmd () {
    data=$1
    opts=$2
    suffix=$3
    dx=$(get_dx $data)
    echo "\"${data}/postProcessing/swakExpression_extremeUy/0/extremeUy\" u ((\$1)*1e6):2 w l $opts t \"${dx}\{\/Symbol m\}m\"${suffix}"
}

study_cases=" \
../conv_study_0.75mum_SolidBoundary_polar_low_res \
../conv_study_1mum_SolidBoundary_polar_low_res \
../conv_study_1.35mum_SolidBoundary_polar_low_res \
../conv_study_2mum_SolidBoundary_polar_low_res \
../conv_study_3mum_SolidBoundary_polar_low_res \
"

j=0
for i in $study_cases
do
    let 'j=j+1'
done
case_count=$j

plt_cmd=""
k=1
for j in $study_cases
do
    lw=3
    lc=$k
    suffix=",\\"
    if [[ $k == 1 ]]; then lw=7; lc=7; fi
    if [[ $k == 2 ]]; then lc="rgbcolor \"0x0000FF\" dt 1"; fi
    if [[ $k == 3 ]]; then lc="3 dt 1"; fi
    if [[ $k == 4 ]]; then lc="2 dt 1"; lw=5; fi
    if [[ $k == 5 ]]; then lc="8 dt 1"; fi
    if [[ $k == 6 ]]; then lc="9 dt 1"; fi
    if [[ $k == 7 ]]; then lc="10 dt 2"; fi
    if [[ $k == 8 ]]; then lc="11 dt 2"; fi
    opts="lw $lw lc $lc"
    if [ $k == $case_count ];then suffix=" ";fi
    plt_cmd="$plt_cmd $(data_plt_cmd $j "$opts" $suffix)"
    let 'k=k+1'
done

cp ${plotfile}.backup $plotfile
sed -i "s#PLOT#$plt_cmd#g" $plotfile
sed -i "s/MAINXRANGE/90:\*/" $plotfile
sed -i "s/#UNCOMMENTFORINSET//g" $plotfile
sed -i "s#INSETRANGE#99.8:100.0#g" $plotfile
sed -i "s#INSETXTICS#98,0.1#g" $plotfile

gnuplot $plotfile
epstopdf jet_speed.eps
rm jet_speed.eps
pdfcrop jet_speed.pdf jet_speed_backup.pdf





cp ${plotfile}.backup $plotfile
sed -i "s#PLOT#$plt_cmd#g" $plotfile
sed -i "s/MAINXRANGE/98:101/" $plotfile
sed -i "s/#KEYOPTS/bottom right/g" $plotfile

gnuplot $plotfile
epstopdf jet_speed.eps
rm jet_speed.eps
pdfcrop jet_speed.pdf jet_speed_zoom.pdf





cp ${plotfile}.backup $plotfile
sed -i "s#PLOT#$plt_cmd#g" $plotfile
sed -i "s/MAINXRANGE/98:101/" $plotfile
sed -i "s/#KEYOPTS/bottom left/g" $plotfile

lc=(7 "rgbcolor \"0x0000FF\"" 3 2 8 9)
tj=(100.4 100.2 100.05 99.76 99.2)
arrow_cmd=" \
set arrow from ${tj[0]}, graph 0 to ${tj[0]}, graph 1 nohead lw 2 lc ${lc[0]}\n \
set arrow from ${tj[1]}, graph 0 to ${tj[1]}, graph 1 nohead lw 2 lc ${lc[1]}\n \
set arrow from ${tj[2]}, graph 0 to ${tj[2]}, graph 1 nohead lw 2 lc ${lc[2]}\n \
set arrow from ${tj[3]}, graph 0 to ${tj[3]}, graph 1 nohead lw 2 lc ${lc[3]}\n \
set arrow from ${tj[4]}, graph 0 to ${tj[4]}, graph 1 nohead lw 2 lc ${lc[4]}\n \
"
sed -i "s/#ARROWS/$arrow_cmd/g" $plotfile

gnuplot $plotfile
epstopdf jet_speed.eps
rm jet_speed.eps
pdfcrop jet_speed.pdf jet_speed_eval.pdf


mv jet_speed_backup.pdf jet_speed.pdf
