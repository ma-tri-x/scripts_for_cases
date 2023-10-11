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
        
    conf_dict["mesh"]["ycenter"] = 0.0
    radius_of_PS = conf_dict["bubble"]["radiusOfVogelBubble"]*1.2
    ycenter_of_PS = conf_dict["bubble"]["heightOfVogelBubble"]
    
    """
    now setting up the case and mesh with the prepared conf_dict
    """
    case = OAFL.Case(conf_dict)
    case.Allclean()
    case.write_template_files_to_OF_files() # *template --> OF files now happening here!
    
    mesh = simple_rect_3D_V2.MeshCalcer(conf_dict,side="all")
    mesh.calc_mesh()
    mesh.write_blockMeshDict()
    
    case.blockMesh()
    case.prepare_snappyHexMeshDict_CAD_and_bubble(refinementCenter=ycenter_of_PS)
    case.snappyHexMesh()
    
    case.set_U_field_zero()
    case.set_alpha_field_Vogel()
    case.adapt_energy()
    case.set_passiveScalar_sinus_schlieren(radius_of_PS=radius_of_PS,
                                           ycenter_of_PS=ycenter_of_PS,
                                           num_per_180_deg=5)
    
    case.decompose()
    

if __name__=="__main__":
    main()
