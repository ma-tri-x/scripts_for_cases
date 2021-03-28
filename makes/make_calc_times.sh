#!/bin/bash

thisdir=$(pwd)

study_cases=" \
../conv_study_0.75mum_refine \
../conv_study_1mum_refine \
../conv_study_1.35mum_refine \
../conv_study_3mum_refine \
../conv_study_2mum_refine \
"

study_cases2=" \
../conv_study_0.6mum_refine \
"

study_cases3=" \
../conv_study_0.5mum_Econst_wp14  \
../conv_study_0.65mum_Econst_wp14  \
../conv_study_0.75mum_Econst_RnChange  \
../conv_study_1.2mum_Econst_RnChange  \
../conv_study_1.35mum_Econst_RnChange  \
../conv_study_1mum_Econst_RnChange  \
../conv_study_2mum_Econst_RnChange  \
../conv_study_3mum_Econst_RnChange  \
"
study_cases4=" \
../conv_study_1mum_Econst_RnChange_maxCo0.1  \
../conv_study_1.2mum_Econst_RnChange_maxCo0.1  \
../conv_study_1.35mum_Econst_RnChange_maxCo0.1  \
../conv_study_2mum_Econst_RnChange_maxCo0.1  \
../conv_study_3mum_Econst_RnChange_maxCo0.1  \
"
study_cases5=" \
../conv_study_1mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus  \
../conv_study_1.35mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus  \
../conv_study_2mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus  \
../conv_study_3mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus  \
"
study_cases6=" \
../conv_study_0.6mum_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus_fromBerlin_naked  \
"

study_cases7=" \
../conv_study_3mum_refine_low_res \
../conv_study_2mum_refine_low_res \
../conv_study_1.35mum_refine_low_res \
../conv_study_1mum_refine_low_res \
../conv_study_0.75mum_refine_low_res \
"

ENDTIME=101e-6

plotfile=plot_calc_times.gnuplot

################# BEGIN FUNCS ###################
get_dx ()
{
    echo "$(python <<< "print(\"${1}\".split(\"mum\")[0].split(\"_\")[-1])")"
}

get_exec_time() {
    echo $(tail -n 60 run.log | grep Exec | tail -n 1 | sed "s/ExecutionTime = //g" | sed "s/ s//g")
}

get_virt_time() {
    echo $(tail -n 60 run.log | grep Take | tail -n 1 | sed "s/Taken time = //g" | sed "s/ Courant.*//g")
}

get_number_of_cells() {
    echo $(grep cells: log.checkMesh | sed "s/[ ]*cells:[ ]*//g")
}

cat_together_input_files() {
    product=""
    for i in $@;do
        product="$product $i"
    done
    echo $product
}

produce_dat_file(){
    study_cases=$1
    outfile=$2
    echo "#cellsize  exec_time  number_of_cells  last_virtual_time" > $outfile
    for i in $study_cases;do
        echo $i
        cd $i
        #refineTimes=$(python getparm.py -q refineTimes -s refine)
        #if [ ! $bla == "y" ];then refineTimes=0;fi
        #cs=$(m4 <<< "esyscmd(perl -e 'printf (  $(python getparm.py -q cellSize -s mesh)*1e6/2**$refineTimes  )')")
        cs=$(get_dx $i)
        #exit 0
        exec_time=$(get_exec_time)
        virt_time=$(get_virt_time)
        nc=$(get_number_of_cells)
        if [[ ! $exec_time == "" ]];then
        echo "$cs  $exec_time  $nc  $virt_time" >> $thisdir/$outfile
        fi
        cd $thisdir
    done
}

plot_it(){
    outfile=$1
    gnuplot $plotfile
    epstopdf calc_times.eps
    pdfcrop calc_times.pdf $outfile
    rm calc_times.eps calc_times.pdf
    cp $plotfile "plot_${outfile%.pdf}.gnuplot"
}

prepare_checkMeshs(){
    echo "preparing checkMesh logs..."
    for i in $@
    do
        check=$(tail -n 2 $i/log.checkMesh | grep End)
        if [[ ! -e $i/log.checkMesh || $check == "" ]];then
            cd $i
            echo "checkMeshing on $i"
            cp constant/polyMesh/temp/* constant/polyMesh
            checkMesh > log.checkMesh
            cd $thisdir
        fi
    done
}
################ END FUNCS ##################

prepare_checkMeshs $study_cases $study_cases2 $study_cases3 $study_cases4 $study_cases5 $study_cases6

produce_dat_file "$(cat_together_input_files $study_cases )" calc_times.dat
produce_dat_file "$(cat_together_input_files $study_cases2)" calc_times2.dat
produce_dat_file "$(cat_together_input_files $study_cases3)" calc_times3.dat
produce_dat_file "$(cat_together_input_files $study_cases4)" calc_times4.dat
produce_dat_file "$(cat_together_input_files $study_cases5)" calc_times5.dat
produce_dat_file "$(cat_together_input_files $study_cases6)" calc_times6.dat
produce_dat_file "$(cat_together_input_files $study_cases7)" calc_times7.dat


cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*(\$4)/${ENDTIME})"

#refine, 0.6 from berlin
sed -i "s/c=1/c=5/g" $plotfile
sed -i "s#FIT#fit \[0.7:\*\] f(x) \"calc_times.dat\" u $usage via a,b#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen\",\\
     \"calc_times2.dat\" u $usage w p ps 2 lw 3 t \"times Xeon-E5\",\\
     \"calc_times.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\",\\
     \"calc_times2.dat\" u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"\"">> $plotfile

plot_it calc_times_refine.pdf
#---------------

cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*${ENDTIME}/(\$4))"

#Econst_RnChange (0.5 and 0.65 with wp14)
sed -i "s#FIT#fit \[0.4:\*\] f(x) \"calc_times3.dat\" u $usage via a,b#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times3.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen\",\\
     \"calc_times3.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\"">> $plotfile

plot_it calc_times_Econst_RnChange.pdf
#---------------

cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*(\$4)/${ENDTIME})"

#Econst_RnChange_maxCo0.1
sed -i "s#FIT#fit \[0.4:\*\] f(x) \"calc_times4.dat\" u $usage via a,b#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times4.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen\",\\
     \"calc_times4.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\"">> $plotfile

plot_it calc_times_Econst_RnChange_maxCo0.1.pdf
#---------------

cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*(\$4)/${ENDTIME})"

#Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus
sed -i "s#FIT#fit \[0.7:\*\] f(x) \"calc_times5.dat\" u $usage via a,b#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times5.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen\",\\
     \"calc_times6.dat\" u $usage w p ps 2 lw 3 t \"times Xeon-E5\",\\
     \"calc_times5.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\",\\
     \"calc_times6.dat\" u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"\"">> $plotfile

plot_it calc_times_Econst_RnChange_maxCo0.2_maxAlphaCo0.08_tRn60mus.pdf
#---------------

#refine_low_res
cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*(\$4)/${ENDTIME})"
sed -i "s#FIT#fit \[0.7:\*\] f(x) \"calc_times7.dat\" u $usage via a,b#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times7.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen\",\\
     \"calc_times7.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\"">> $plotfile

plot_it calc_times_refine_low_res.pdf
