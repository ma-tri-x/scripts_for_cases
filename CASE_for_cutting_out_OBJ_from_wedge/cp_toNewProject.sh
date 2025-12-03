if [ $# == 0 ];then
    echo "please give destiny dir"
    exit 1
fi

thisdir=$(dirname $0)

destDir=$1

if [ ! -d $destDir ];then
    mkdir -p $destDir
fi

cp -r $thisdir/0 $destDir
cp -r $thisdir/system $destDir
cp -r $thisdir/constant $destDir
cp -rf $thisdir/scripts_repo $destDir
cp $thisdir/*.sh $destDir
cp $thisdir/*.template $destDir
cp $thisdir/*.backup $destDir
cp $thisdir/*.py $destDir
cp $thisdir/*.gnuplot $destDir
cp $thisdir/All* $destDir
cp $thisdir/*.json $destDir
cp $thisdir/LUT_R0_Rn_Rmax.dat $destDir
if [ -d $thisdir/GilmoreODEsolver ];then cp -r $thisdir/GilmoreODEsolver $destDir;fi
if [ -d $thisdir/states ];then cp -r $thisdir/states $destDir;fi
if [ -d $thisdir/CAD ];then cp -r $thisdir/CAD $destDir;fi
if [ -d $thisdir/gilmore_runs ];then cp -r $thisdir/gilmore_runs $destDir;fi
if [ -d $thisdir/meshespython ];then cp -r $thisdir/meshespython $destDir;fi
