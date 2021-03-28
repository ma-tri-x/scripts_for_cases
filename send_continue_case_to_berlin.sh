#!/bin/bash

thisdir=$(pwd)

vpn=$(ifconfig | grep vpn)

if [ ! "$vpn" != "" ];then
    echo "your vpn is not active"
    exit 1
fi

certain_case=" \
../conv_study_0.6mum_Econst_RnChange_stbAc09 \
"

for i in $certain_case
do
    cd $i
    bash cp_toNewProject.sh ../temp
    sed -i "s/startFrom.*;/startFrom    latestTime;/g" ../temp/system/controlDict
    sed -i "s/^writeInterval.*;/writeInterval    150;/g" ../temp/system/controlDict
    cat ../temp/system/controlDict
    echo "check it. Proceed? [y/n]"
    read bla
    if [ ! $bla == "y" ];then exit 1;fi
    end=$(python find_biggestNumber.py -p processor0)
    for j in proc*
    do
        mkdir -p ../temp/$j
        cp -r $j/constant ../temp/$j
        cp -r $j/$end ../temp/$j
    done
    echo "tarring $i"
    name=upload_${i#../}.tar.gz
    tar czf $name ../temp && \
    scp $name ma-tri-x@berlin.physik3.uni-goettingen.de:~/2019WiSe2020/foamProjects/ && \
    rm -rf ../temp
    
    cd $thisdir
done
