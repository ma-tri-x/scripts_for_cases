. tools/makeThirdPartyFunctionsForRPM

export QT_QMAKE_EXECUTABLE=/usr/share/qt4/bin/qmake
export QT_BIN_DIR=/usr/share/qt4/bin
echo "Building ParaView 4.4.0"
            ( rpm_make -p ParaView-4.4.0 -s ParaView-4.4.0.spec -u http://downloads.sourceforge.net/project/foam-extend/ThirdParty/ParaView-v4.4.0-source.tar.gz \
                -f --define='_qmakePath $QT_BIN_DIR/qmake'
            )

sed -i "s/MATCH \"\[345\]/MATCH \"\[3459\]/g" ./rpmBuild/BUILD/ParaView-v4.4.0-source/VTK/CMake/vtkCompilerExtras.cmake
sed -i "s/MATCH \"\[345\]/MATCH \"\[3459\]/g" ./rpmBuild/BUILD/ParaView-v4.4.0-source/VTK/CMake/GenerateExportHeader.cmake

if [ -z "ENTERED_COMPILER_VARS_AS_YOU_SAID" ]
then
    echo "now go into $WM_PROJECT_DIR/ThirdParty/rpmBuild/BUILD/ParaView-v4.4.0-source"
    echo "and modify the CMakeCache.txt so that everywhere where it says \"COMPILER\" the gcc-5 and g++-5 are inserted accordingly"
    echo "then do"
    echo "export ENTERED_COMPILER_VARS_AS_YOU_SAID=1"
    exit 1
fi

thisdir=$(pwd)
paraviewdir=./rpmBuild/BUILD/ParaView-v4.4.0-source
mkdir $paraviewdir/buildObj
cd $paraviewdir/buildObj
cmake ..

make
make install
cd $thisdir
