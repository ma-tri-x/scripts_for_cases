#!/bin/bash

stitchMesh wall wall2 -perfect -overwrite > stitchMesh.log
# rm -f constant/polyMesh/faceZones.gz
rm -f 0/meshPhi*