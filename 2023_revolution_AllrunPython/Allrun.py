#!/bin/python

import os, sys, argparse, glob, time
import numpy as np
import OFAllFunctionLibrary as OAFL
import subprocess
from meshespython import *

def main():
    case = OAFL.Case()
    
    case.Allclean()
    
    mesh = coreCartRegUnbound.MeshCalcer()
    mesh.calc_mesh()
    mesh.write_blockMeshDict()
    
    case.blockMesh()
    
    case.set_U_field_zero()
    case.set_alpha_field_ellipse()
    case.adapt_pV()
    case.set_passiveScalar_layeredColors()
    
    case.decompose()
    

if __name__=="__main__":
    main()
