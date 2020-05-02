#!/bin/bash

meshTemplate=constant/polyMesh/1d.m4.template
meshFile=constant/polyMesh/1d.m4
 
 bash Allclean

 cp $meshTemplate $meshFile
 sed -i "s/_RESOLUTION/180/" $meshFile
 sed -i "s/_CELLSIZE/3e-6/" $meshFile
 sed -i "s/_XPOS/10e-6/g" $meshFile
 sed -i "s/_XFPOS/70e-3/g" $meshFile
 
 m4 $meshFile > constant/polyMesh/blockMeshDict
 
 blockMesh