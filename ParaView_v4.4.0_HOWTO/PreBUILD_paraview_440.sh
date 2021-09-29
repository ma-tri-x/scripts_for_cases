#done before Build:
# add repository for qt4
sudo add-apt-repository ppa:rock-core/qt4
#install qt4
sudo apt install cmake gcc g++ qt{4,5}-qmake libqt4-dev
sudo apt install qt4-dev-tools

sudo apt install cmake libavcodec-dev libavformat-dev libavutil-dev libboost-dev libdouble-conversion-dev libeigen3-dev libexpat1-dev libfontconfig-dev libfreetype6-dev libgdal-dev libglew-dev libhdf5-dev libjpeg-dev libjsoncpp-dev liblz4-dev liblzma-dev libnetcdf-dev libnetcdf-cxx-legacy-dev libogg-dev libpng-dev libpython3-dev libqt5opengl5-dev libqt5x11extras5-dev libsqlite3-dev libswscale-dev libtheora-dev libtiff-dev libxml2-dev libxt-dev qtbase5-dev qttools5-dev zlib1g-dev
#sudo apt install vtk
#sudo apt search vtk
#sudo apt install vtk7
#sudo apt search gcc-7
#sudo apt install gcc-7
#sudo apt install clang-7

#Add xenial to /etc/apt/sources.list
#sudo nano /etc/apt/sources.list
#add the lines:
sudo echo "deb http://dk.archive.ubuntu.com/ubuntu/ xenial main" >> /etc/apt/sources.list
sudo echo "deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list

sudo apt update
sudo apt install g++-5 gcc-5

#then comment out the lines again
#sudo nano /etc/apt/sources.list
sed -i "s+deb http://dk.archive.ubuntu.com/ubuntu/ xenial main+#deb http://dk.archive.ubuntu.com/ubuntu/ xenial main+g" /etc/apt/sources.list
sed -i "s+deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe+#deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe+g" /etc/apt/sources.list

export CC=/usr/bin/gcc-5
export CXX=/usr/bin/g++-5

#if sources are already there, go to them
#cd $WM_THIRD_PARTY_DIR/rpmBuild/BUILD/ParaView-v4.4.0-source
#edit CMakeCache.txt and enter gcc-5 and g++-5 everywhere where COMPILER vars are set.

echo "now do"
echo "bash BUILD_paraview_440.sh"
