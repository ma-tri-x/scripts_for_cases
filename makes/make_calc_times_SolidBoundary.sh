#!/bin/bash

thisdir=$(pwd)

study_cases=" \
../conv_study_3mum_SolidBoundary_refine_low_res_XF100 \
../conv_study_2mum_SolidBoundary_refine_low_res_XF100 \
../conv_study_1.35mum_SolidBoundary_refine_low_res_XF100 \
../conv_study_1mum_SolidBoundary_refine_low_res_XF100 \
"
# ../conv_study_0.75mum_SolidBoundary_refine_low_res_XF100 \

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
    method=$3
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
        if [ $method == "chM" ];then
            nc=$(get_number_of_cells_chM)
        else
            nc=$(get_number_of_cells_bM)
        fi
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
    #cp $plotfile "plot_${outfile%.pdf}.gnuplot"
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

prepare_checkMeshs $study_cases

produce_dat_file "$(cat_together_input_files $study_cases )" calc_times_SolidBoundary.dat "chM"


cp $plotfile.backup $plotfile

usage="1:((\$2)/60.*(\$4)/${ENDTIME})"

# sed -i "s/c=1/c=5/g" $plotfile
sed -i "s#FIT#fit \[0.7:\*\] f(x) \"calc_times_SolidBoundary.dat\" u $usage via a,b#g" $plotfile
echo "f(x) t sprintf(\"%.1f /(res.)^{%.1f} + %.1f\",a,b,c),\\
     \"calc_times_SolidBoundary.dat\"  u $usage w p ps 2 lw 3 t \"times Ryzen\",\\
     \"calc_times_SolidBoundary.dat\"  u 1:((\$3)/1e3) w p ps 2 pt 2 lw 3 lc 8 axis x1y2 t \"amount of cells\"">> $plotfile

plot_it calc_times_SolidBoundary.pdf
#---------------
