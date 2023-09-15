#!/bin/python

import os, sys, argparse, glob, time,json
import numpy as np
import OFAllFunctionLibrary as OAFL
import subprocess
from meshespython import *

def main():
    """
    changed library so that Case and Mesh are independent and point(!)
    to the dictionary "conf_dict" loaded HERE in Allrun.py. So conf_dict can be prepared here:
    preparation:
    """
    conf_dict = {}
    with open("conf_dict.json","r") as f:
        conf_dict = json.load(f)
    
    OhInv = 400.0
    Pst = 4.1
    S = 0.6
    alpha = S**3
    print("the number of time-steps scales with sqrt(RE) -- see eqs.")
    dimless_t_end = 2.0
    n_t = 500
    print(f"we want {n_t} time-steps till dimless t_end {dimless_t_end}")
    # n = cells per curvature radius in C
    n = 10
    v_s = 1450. #m/s
    rho = conf_dict["liquid"]["rho"]
    maxAcousticCo = conf_dict["controlDict"]["maxAcousticCo"]
    sigma = conf_dict["transportProperties"]["sigma"]
    
    RE = (n_t*S**4*maxAcousticCo/dimless_t_end/n/v_s/np.sqrt(rho))**2 * 2*Pst*sigma
    print("RE = {}".format(RE))
    
    # Rc = curvature radius in C
    Rc = alpha * S * RE
    
    cellsize = Rc/n
    a = S*RE
    c = a/S**3
    print("cellsize = {}".format(cellsize))
    print("core size: {} x {}".format(c,2*c))
    print("core cell amount: {}".format(round(c*2*c/cellsize**2)))
    print("n_phi (cells per 180 deg: {}".format(2*(c+c)/cellsize))
    
    conf_dict["mesh"]["cellSize"] = cellsize
    conf_dict["mesh"]["meshCoreSize"] = c
    conf_dict["bubble"]["Rn"] = RE
    conf_dict["bubble"]["aimedRn"] = RE
    conf_dict["bubble"]["Rmax"] = RE
    conf_dict["bubble"]["Rstart"] = RE
    conf_dict["liquid"]["pInf"] = 2.0*Pst*sigma/RE
    conf_dict["liquid"]["mu"] = np.sqrt(sigma*RE*rho)/OhInv
    
    conf_dict["bubble"]["ycenter"] = 0.0
    
    with open("conf_dict_editedByAllrun.json","w") as f:
        json.dump(conf_dict,f)
    
    
    """
    now setting up the case and mesh with the prepared conf_dict
    """
    case = OAFL.Case(conf_dict)
    case.Allclean()
    case.write_template_files_to_OF_files() # *template --> OF files now happening here!
    
    mesh = coreCartRegUnbound.MeshCalcer(conf_dict)
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
