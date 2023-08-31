#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import OFAllFunctionLibrary as OAFL
import subprocess
from meshespython import *

def main():
    case = OAFL.Case()
    
    mesh = coreCartRegUnbound.MeshCalcer()
    mesh.calc_mesh()
    mesh.write_blockMeshDict()
    
    case.blockMesh()

if __name__=="__main__":
    main()
