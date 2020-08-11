#!/bin/bash

getThisApplication ()
{
    grep "^application" system/controlDict | sed "s/application *\([a-zA-Z0-9]*\);/\1/"
}

getMeshFile ()
{
    grep "^m4 constant/polyMesh/" Allrun | sed "s#m4[ ]*constant/polyMesh/##" | sed "s#[ ]*>[ ]*constant/polyMesh/blockMeshDict##"
}

shopt -s extglob  # to enable extglob
#cp !(b*) new_dir/
##where !(b*) excludes all b* files.


if [ ! -d startConditions ]
then
    mkdir startConditions
fi

i=0
while [ -d `printf "startConditions/%03d" $i` ] ; do
    i=`expr $i + 1`
done

savePath=$(printf "startConditions/%03d" $i)

mkdir -p $savePath/constant/polyMesh
mkdir -p $savePath/system
mkdir -p $savePath/0/backup

cp -r constant/!(*~|*.gz|boundary|polyMesh)    $savePath/constant
cp constant/polyMesh/!(*~|*.gz|boundary) $savePath/constant/polyMesh
cp -r 0/backup/!(*~) $savePath/0/backup
cp -r system/!(*~)   $savePath/system
cp *.sh        $savePath
cp *.py        $savePath
cp *.gnuplot*  $savePath
cp All*        $savePath


# find and copy solver to working case
thisdir=$(pwd)
solver=`getThisApplication`
cd $WM_PROJECT_DIR/applications/solvers
pathToSolver=$(find -name $solver)
cd $pathToSolver
pathToSolver=$(pwd)
cd $thisdir
cp -r $pathToSolver $savePath
rm -r $savePath/$solver/Make/linux*
###########


shopt -u extglob # to disable extglob