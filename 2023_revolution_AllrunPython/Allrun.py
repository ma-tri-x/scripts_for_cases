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
        
    """
    now setting up the case and mesh with the prepared conf_dict
    """
    case = OAFL.Case(conf_dict)
    case.Allclean()
    case.write_template_files_to_OF_files() # *template --> OF files now happening here!
    case.copy_0backup()
    
    #mesh = simple_rect_3D_V2.MeshCalcer(conf_dict)
    #mesh.calc_mesh()
    #mesh.write_blockMeshDict()
    
    case.m4Mesh()
    
    #mesh.write_blockMeshDict()
    
    case.blockMesh()
    
    #case.stitchMesh()
    dinit_avg = 0.5*(case.conf_dict["bubble"]["D_init"] + case.conf_dict["secondBubble"]["D_init"])
    case.refineMesh2D(cellSetDictBackup="cellSetDictRectangles.1.backup",cellSetCenter=dinit_avg)
    
    #case.makeAxialMesh()
    #case.collapseEdges()
    
    #case.copy_0backup()
    
    #case.changeDictionary()
    #case.stitchMesh()
    #cutting away cylinder:
    #case.prepare_snappyHexMeshDict_CAD_and_bubble(refineBubblePart=False)
    #case.snappyHexMesh()
    #os.system("sed -i \"s/side/side_withG/g\" constant/polyMesh/blockMeshDict")
    #os.system("sed -i \"s/_ALLRUN-BCAMPLITUDE/0.0/g\" 0/p_rgh")
    #os.system("sed -i \"s/(0 -9.81 0)/(0 0 0)/g\" constant/g")
    
    
    case.makeAxialMesh()
    case.collapseEdges()
    
    case.copy_0backup()
    
    case.changeDictionary()
    
    case.set_U_field_zero()
    
    #rho_l0 = case.conf_dict["liquid"]["rho"]
    #gVector = case.conf_dict["gravity"]["g"].replace(" ",",")
    #case.run_funkySetFields_command(case.pVar,f"{case.pInf} + {rho_l0}*(vector{gVector} & vector(pos().x,pos().y,pos().z))","")
    
    print("remember: bubbleOne needs to sit in the positive PassiveScalar region!")
    print("remember: bubbleTwo needs to sit in the negative PassiveScalar region!")
    
    case.set_passiveScalar_layeredColors_doubleBubble()
    case.set_alpha_field_bubble_PS_range(passiveScalar_range=[0.0, 10.0],D_init=case.conf_dict["bubble"]["D_init"],R0=case.conf_dict["bubble"]["Rstart"])
    #case.set_alpha_field_bubble_PS_range(passiveScalar_range=[-10.0,0.0],D_init=case.conf_dict["secondBubble"]["D_init"],R0=case.conf_dict["secondBubble"]["Rstart"])
    
    R01,Rn1,pBubble1 = case.get_correct_R0_Rn_pBubble_by_fitfunction_and_PS(passiveScalar_range=[0.0, 10.0],outfilename="0/get_alpha2_vol_t0_bubble1",
                                                                         Rmax=case.conf_dict["bubble"]["Rmax"])
    #R02,Rn2,pBubble2 = case.get_correct_R0_Rn_pBubble_by_fitfunction_and_PS(passiveScalar_range=[-10.0,0.0],outfilename="0/get_alpha2_vol_t0_bubble2",
    #                                                                     Rmax=case.conf_dict["secondBubble"]["Rmax"])
    
    case.write_Rn_and_aimedRn_to_OFdictionary(Rn1,dictionary="constant/BubblesProperties",
                                             replaceable_string_Rn="_OFALLFUNC-RN",
                                             replaceable_string_aimedRn="_OFALLFUNC-AIMEDRN")
    
    case.set_bubble_pressure_PS_range(passiveScalar_range=[0.0,10.0],pBubble=pBubble1)
    # secondBubble will be put at maximum extension of first bubble in Allrun2.py
    
    Tc1 = 0.91468*case.conf_dict["bubble"]["Rmax"]*np.sqrt(998./(case.pInf-case.pV))
    #Tc2 = 0.91468*case.conf_dict["secondBubble"]["Rmax"]*np.sqrt(998./(case.pInf-case.pV))
    
    case.replace_end_time_in_controlDict(Tc1)
    
    case.decompose()
    
    print("remember to run with localMassCorr_singleBubble first:")
    threads = case.conf_dict["decompose"]["threads"]
    print(f"mpirun -np {threads} localMassCorr_singleBubble -parallel > run.log 2>&1 &")

if __name__=="__main__":
    main()
