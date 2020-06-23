#!/bin/bash
pi="3.14159265358979323846264338327950288"

thisdir=$(pwd)

plotfile=plot_Rt.gnuplot

get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

get_theta_rad () {
    echo $(m4 <<< "esyscmd(perl -e 'printf ( $(cat THETA) /180*$pi  )')")
}

data_plt_cmd () {
    data=$1
    opts=$2
    suffix=$3
    theta=$(get_theta_rad)
    dx=$(get_dx $data)
    echo "\"${data}/postProcessing/volumeIntegrate_volumeIntegral/0/alpha2\" using ((\$1)*1e6):(((\$2)*3./(4.*( tan(${theta}) )**2))**(1/3.)*1e6) w l lw 3 $opts t \"${dx}\{\/Symbol m\}m\"${suffix}"
}

# study_cases=" \
# ../sp_conv_study_3mum_XF100 \
# ../sp_conv_study_2mum_XF100 \
# ../sp_conv_study_1.35mum_XF100 \
# ../sp_conv_study_1mum_XF100 \
# ../sp_conv_study_0.6mum_XF100 \
# ../sp_conv_study_0.4mum_XF100 \
# ../sp_conv_study_0.2mum_XF100 \
# ../sp_conv_study_0.1mum_XF100 \
# ../sp_conv_study_0.09mum_XF100 \
# "

study_cases=" \
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

j=0
for i in $study_cases
do
    let 'j=j+1'
done
number_of_cases=$j


cp $plotfile.backup $plotfile
plt_cmd=""
j=1
for i in $study_cases
do
    cd $i
    suffix=","
    if [ $j == $number_of_cases ];then suffix=" ";fi
    if [ $j == 5 ];then   plt_cmd="$plt_cmd $(data_plt_cmd $i "lc 3 dt 2" $suffix)"
    elif [ $j -gt 8 ];then plt_cmd="$plt_cmd $(data_plt_cmd $i "dt 2" $suffix)";
    else plt_cmd="$plt_cmd $(data_plt_cmd $i " " $suffix)";fi
    let 'j=j+1'
    cd $thisdir
done

sed -i "s#PLOT#$plt_cmd#g" $plotfile
sed -i "s#INSETRANGE#91:92.5#g" $plotfile
sed -i "s#INSETXTICS#91,0.5#g" $plotfile

gnuplot $plotfile
epstopdf Rt.eps
pdfcrop Rt.pdf Rt.pdf
rm Rt.eps
