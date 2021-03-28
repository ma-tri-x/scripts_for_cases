#!/bin/bash

stitchMesh wall wall2 -perfect -overwrite > log.stitchMesh
# rm -f constant/polyMesh/faceZones.gz
rm -f 0/meshPhi*
