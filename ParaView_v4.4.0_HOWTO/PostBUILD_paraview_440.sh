#!/bin/bash

echo "this is a manual. Don't execute, read and do manually!!!"
exit 1

# in order to read in the directory of ParaView-4.4.0 into the PATH variable, edit
nano $WM_PROJECT_DIR/etc/settings.sh
# and modify the respective if clause so that something like this is there:
[ -z "$PARAVIEW_SYSTEM" ] && [ ! -z $WM_THIRD_PARTY_USE_PARAVIEW_440 ] && [ -e $WM_THIRD_PARTY_DIR/packages/ParaView-4.4.0_KK/platforms ] && {
    _foamAddPath $PARAVIEW_BIN_DIR
}
# modify prefs.sh such that:
#----------
# System installed ParaView
export PARAVIEW_SYSTEM=""
export PARAVIEW_DIR=$WM_THIRD_PARTY_DIR/packages/ParaView-4.4.0_KK/platforms/linux64GccDPOpt
export PARAVIEW_BIN_DIR=$PARAVIEW_DIR/bin
export PATH=$PARAVIEW_BIN_DIR:$PATH
#----------
#is there. watch out with the exact path for PARAVIEW_DIR on your system. If the compilation went wrong, this path does not exist in .../packages/...
# now source the etc/bashrc and have a look at your PATH variable:
echo $PATH | grep Para
# is it there?
