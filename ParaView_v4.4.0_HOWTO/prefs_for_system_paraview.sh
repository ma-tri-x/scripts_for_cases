#----------------------------------*-sh-*--------------------------------------
# =========                 |
# \\      /  F ield         | foam-extend: Open Source CFD
#  \\    /   O peration     | Version:     4.1
#   \\  /    A nd           | Web:         http://www.foam-extend.org
#    \\/     M anipulation  | For copyright notice see file Copyright
#------------------------------------------------------------------------------
# License
#     This file is part of foam-extend.
#
#     foam-extend is free software: you can redistribute it and/or modify it
#     under the terms of the GNU General Public License as published by the
#     Free Software Foundation, either version 3 of the License, or (at your
#     option) any later version.
#
#     foam-extend is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with foam-extend.  If not, see <http://www.gnu.org/licenses/>.
#
# File
#     etc/prefs.sh.mingw
#
# Description
#     Preset variables for the FOAM configuration - POSIX shell syntax
#     for MS Windows
#
#     The prefs.sh file will be sourced by the FOAM etc/bashrc when it is
#     found
#
#------------------------------------------------------------------------------

# Specify system compiler
# ~~~~~~~~~~~~~~~~~~~~~~~
#compilerInstall=System
#compilerInstall=FOAM

# Specify system openmpi
# ~~~~~~~~~~~~~~~~~~~~~~
#
# Normally, you don't need to set more than these 3 env. variables
# The other openmpi related variables will be initialized using
# the command mpicc --showme:
#
#export WM_MPLIB=SYSTEMOPENMPI
#export OPENMPI_DIR=$MPI_ROOTDIR
#export OPENMPI_BIN_DIR=$OPENMPI_DIR/bin
#
#export OPENMPI_LIB_DIR="`$OPENMPI_BIN_DIR/mpicc --showme:libdirs`"
#export OPENMPI_INCLUDE_DIR="`$OPENMPI_BIN_DIR/mpicc --showme:incdirs`"
#export OPENMPI_COMPILE_FLAGS="`$OPENMPI_BIN_DIR/mpicc --showme:compile`"
#export OPENMPI_LINK_FLAGS="`$OPENMPI_BIN_DIR/mpicc --showme:link`"

# Specify system installed ThirdParty packages/libraries
# NB: The packages installed under $WM_THIRD_PARTY_DIR
#     will always override these values.
#     So build your ThirdParty directory accordingly.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# System installed CUDA
#export CUDA_SYSTEM=1
#export CUDA_DIR=path_to_system_installed_cuda
#export CUDA_BIN_DIR=$CUDA_DIR/bin
#export CUDA_LIB_DIR=$CUDA_DIR/lib
#export CUDA_INCLUDE_DIR=$CUDA_DIR/include
#export CUDA_ARCH=sm_20

# System installed Mesquite
#export MESQUITE_SYSTEM=1
#export MESQUITE_DIR=$WM_THIRD_PARTY_DIR/packages/mesquite-2.1.2
#export MESQUITE_BIN_DIR=$MESQUITE_DIR/bin
#export MESQUITE_LIB_DIR=$MESQUITE_DIR/lib
#export MESQUITE_INCLUDE_DIR=$MESQUITE_DIR/include

# System installed Metis
#export METIS_SYSTEM=1
#export METIS_DIR=$WM_THIRD_PARTY_DIR/packages/metis-5.1.0
#export METIS_BIN_DIR=$METIS_DIR/bin
#export METIS_LIB_DIR=$METIS_DIR/lib
#export METIS_INCLUDE_DIR=$METIS_DIR/include

# System installed ParMetis
#export PARMETIS_SYSTEM=1
#export PARMETIS_DIR=$WM_THIRD_PARTY_DIR/packages/parmetis-4.0.3
#export PARMETIS_BIN_DIR=$PARMETIS_DIR/bin
#export PARMETIS_LIB_DIR=$PARMETIS_DIR/lib
#export PARMETIS_INCLUDE_DIR=$PARMETIS_DIR/include

# System installed ParMGridgen
#export PARMGRIDGEN_SYSTEM=1
#export PARMGRIDGEN_DIR=$WM_THIRD_PARTY_DIR/packages/ParMGridGen-1.0
#export PARMGRIDGEN_BIN_DIR=$PARMGRIDGEN_DIR/bin
#export PARMGRIDGEN_LIB_DIR=$PARMGRIDGEN_DIR/lib
#export PARMGRIDGEN_INCLUDE_DIR=$PARMGRIDGEN_DIR/include

# System installed Libccmio
#export LIBCCMIO_SYSTEM=1
#export LIBCCMIO_DIR=path_to_system_installed_libccmio
#export LIBCCMIO_BIN_DIR=$LIBCCMIO_DIR/bin
#export LIBCCMIO_LIB_DIR=$LIBCCMIO_DIR/lib
#export LIBCCMIO_INCLUDE_DIR=$LIBCCMIO_DIR/include

# System installed Scotch
#export SCOTCH_SYSTEM=1
#export SCOTCH_DIR=$WM_THIRD_PARTY_DIR/packages/scotch_6.0.4
#export SCOTCH_BIN_DIR=$SCOTCH_DIR/bin
#export SCOTCH_LIB_DIR=$SCOTCH_DIR/lib
#export SCOTCH_INCLUDE_DIR=$SCOTCH_DIR/include

# System installed CMake
#export CMAKE_SYSTEM=1
#export CMAKE_DIR=path_to_system_installed_cmake
#export CMAKE_BIN_DIR=$CMAKE_DIR/bin

# System installed Python
#export PYTHON_SYSTEM=1
#export PYTHON_DIR=path_to_system_installed_python
#export PYTHON_BIN_DIR=$PYTHON_DIR/bin

# System installed PyFoam
#export PYFOAM_SYSTEM=1
#export PYFOAM_DIR=path_to_system_installed_python
#export PYFOAM_BIN_DIR=$PYFOAM_DIR/bin

# System installed hwloc
#export HWLOC_SYSTEM=1
#export HWLOC_DIR=path_to_system_installed_hwloc
#export HWLOC_BIN_DIR=$HWLOC_DIR/bin

# System installed Qt
# This is the only package we assume is system installed by default.
# So we don't use a variable called QT_SYSTEM, but instead a variable
# called QT_THIRD_PARTY in order to override to the ThirdParty QT
# package.
#
# If you choose to use the system installed version of QT, keep
# the variable QT_THIRD_PARTY commented, and uncomment the initialization
# of the variable QT_DIR and QT_BIN_DIR. Make sure both variables are
# properly initialized.
#
# If you choose instead to use the ThirdParty version of QT, only uncomment
# the variable QT_THIRD_PARTY and set it to 1. Keep the initialization
# of the variables QT_DIR nd QT_BIN_DIR commented. The QT ThirdParty scripts
# will take care of setting the variables QT_DIR and QT_BIN_DIR to the
# proper values.
#
#export QT_THIRD_PARTY=""
export QT_DIR=/usr #$WM_THIRD_PARTY_DIR/rpmBuild/BUILD/qt-everywhere-opensource-src-4.8.6/ #path_to_system_installed_qt
export QT_BIN_DIR=$QT_DIR/bin

# prefix to PATH
_foamAddPath()
{
    echo "SEEEEEEEEEEEEEEEEEEEEEEEEEES"
    while [ $# -ge 1 ]
    do
        export PATH=$1:$PATH
        shift
    done
}

# System installed ParaView
export PARAVIEW_SYSTEM="1"
export PARAVIEW_DIR=/usr/lib/x86_64-linux-gnu/paraview-5.10 #/usr #$WM_THIRD_PARTY_DIR/packages/ParaView-4.4.0_KK/platforms/linux64GccDPOpt
export PARAVIEW_BIN_DIR=/usr/bin
#export PATH=$PARAVIEW_BIN_DIR:$PATH

# System installed bison
#export BISON_SYSTEM=1

# System installed flex
#export FLEX_SYSTEM=1

# System installed m4
#export M4_SYSTEM=1

# Specify ParaView version
# ~~~~~~~~~~~~~~~~~~~~~~~~
#export ParaView_VERSION=git        # eg, cvs/git version
#export ParaView_MAJOR=3.7


# System identifier for the FOAM CDash test harness on foam-extend
#
# By default, your system FQN/hostname will be used as the system identifier
# when publishing your test harness results on the FOAM CDash server
# on foam-extend.
# You can override your identifier using this environment variable
#export CDASH_SUBMIT_LOCAL_HOST_ID=choose_your_CDash_system_identifer

# Buildname suffix for the FOAM CDash test harness on foam-extend
# By default, the git branch name and git revision number will be
# appended to the CDash build name.
# Otherwise, for users not using git, or wanting to provide additionnal
# information, simply initialize the CDASH_SCM_INFO with the proper information
#export CDASH_SCM_INFO=your_SCM_information

# Mac OS X MacPorts root directory.
# The default value is '/opt/local/etc/macports'.
# In order to disable the usage of MacPorts on Mac OSX, simply initialize this
# variable to a non-existing directory, or to a dummy value.
#export MACOSX_MACPORTS_ROOT="_not_using_"

# ThirdParty packages: build control variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# By enabling any of these variables, you will active the compilation and
# installation of the corresponding ThirdParty package
#
# For AllMake.stage1
#export WM_THIRD_PARTY_USE_GCC_492=1
#export WM_THIRD_PARTY_USE_GCC_484=1
#export WM_THIRD_PARTY_USE_GCC_463=1
#export WM_THIRD_PARTY_USE_GCC_451=1
#export WM_THIRD_PARTY_USE_GCC_445=1
#export WM_THIRD_PARTY_USE_PYTHON_27=1
#export WM_THIRD_PARTY_USE_M4_1416=1
#export WM_THIRD_PARTY_USE_BISON_27=1
#export WM_THIRD_PARTY_USE_FLEX_2535=1
#export WM_THIRD_PARTY_USE_CMAKE_322=1

#
# For AllMake.stage2
#export WM_THIRD_PARTY_USE_OPENMPI_184=1
#export WM_THIRD_PARTY_USE_OPENMPI_184_ConfigureAdditionalArgs='--enable-mpi-cxx --with-openib=/usr --with-openib-libdir=/usr/lib64'
#export WM_THIRD_PARTY_USE_OPENMPI_165=1
#export WM_THIRD_PARTY_USE_OPENMPI_165_ConfigureAdditionalArgs='--enable-mpi-cxx --with-openib=/usr --with-openib-libdir=/usr/lib64'
#export WM_THIRD_PARTY_USE_OPENMPI_15=1
#export WM_THIRD_PARTY_USE_OPENMPI_143=1
#export WM_THIRD_PARTY_USE_OPENMPI_141=1

#
# For AllMake.stage3
#export WM_THIRD_PARTY_USE_METIS_510=1
#export WM_THIRD_PARTY_USE_PARMGRIDGEN_10=1
#export WM_THIRD_PARTY_USE_LIBCCMIO_261=1
#export WM_THIRD_PARTY_USE_MESQUITE_230=1
#export WM_THIRD_PARTY_USE_SCOTCH_604=1
##export WM_THIRD_PARTY_USE_SCOTCH_600=1
#export WM_THIRD_PARTY_USE_PARMETIS_403=1
##export WM_THIRD_PARTY_USE_ZOLTAN_36=1
#export WM_THIRD_PARTY_USE_PYFOAM_069=1
#export WM_THIRD_PARTY_USE_HWLOC_201=1
#export WM_THIRD_PARTY_USE_HWLOC_1101=1
#export WM_THIRD_PARTY_USE_HWLOC_172=1

#
# For AllMake.stage4
#export WM_THIRD_PARTY_USE_QT_5111=1
#export WM_THIRD_PARTY_USE_QT_5111=1
#export WM_THIRD_PARTY_USE_QT_486=1
#export WM_THIRD_PARTY_USE_PARAVIEW_431=1
#export WM_THIRD_PARTY_USE_PARAVIEW_410=1
#export PV_PLUGIN_PATH=$WM_THIRD_PARTY_DIR/rpmBuild/BUILD/ParaView-v4.3.1-source/Plugins/
export PV_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/paraview-5.10/plugins

# Add in preset user preferences: will override site preferences
#if [ -e $WM_PROJECT_USER_DIR/etc/prefs.sh ]
#then
#    _foamSource $WM_PROJECT_USER_DIR/etc/prefs.sh
#fi
# ----------------------------------------------------------------- end-of-file


