#!/bin/bash

thisdir=$(pwd)

study_cases=" \
../sp_conv_study_3mum \
../sp_conv_study_2mum \
../sp_conv_study_1.35mum \
../sp_conv_study_1mum \
../sp_conv_study_0.6mum \
../sp_conv_study_0.4mum \
../sp_conv_study_0.2mum \
"
study_cases2=" \
../sp_conv_study_0.1mum \
../sp_conv_study_0.05mum \
../sp_conv_study_0.02mum \
"

ENDTIME=101e-6

plotfile=plot_calc_times_spherical.gnuplot

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

get_number_of_cells_chM() {
    echo $(grep cells: log.checkMesh | sed "s/[ ]*cells:[ ]*//g")
}

get_number_of_cells_bM() {
    echo $(grep nCells: log.blockMesh | sed "s/[ ]*nCells:[ ]*//g")
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
        nc=$(get_number_of_cells_bM)
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

# prepare_checkMeshs $study_cases

produce_dat_file "$(cat_together_input_files $study_cases )" calc_times_sp.dat
produce_dat_file "$(cat_together_input_files $study_cases2 )" calc_times_sp2.dat

cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*(\$4)/${ENDTIME})"

#sed -i "s/c=1/c=5/g" $plotfile
sed -i "s#FIT#fit \[\*:\*\] f(x) \"calc_times_sp.dat\" u $usage via a,b,c#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times_sp.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen 1 thread\",\\
     \"calc_times_sp2.dat\" u $usage w p ps 2 lw 3 t \"times Ryzen 8 threads\",\\
     \"calc_times_sp.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\",\\
     \"calc_times_sp2.dat\" u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"\"">> $plotfile

plot_it calc_times_sp.pdf
#---------------
